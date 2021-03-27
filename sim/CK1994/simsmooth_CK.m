function [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, RQR, s0, P0)
% This code samples states and forecasts from a state space model of the
% following form: 
% y_t = Z s_t + e_t; e_t ~N(0, H)
% s_t = T s_t-1 + u_t; u_T ~ N(0, RQR)
% See Carter and Kohn (1994, Biometrika) for the original reference 
% or Kim and Nelson (1998) for a textbook treatment.
% Compared to standard implementations, this code can be applied for both
% unconditional and hard&soft conditional forecasting. 
% General input arguments are: Y_o, Nn x Nt matrix of observations, state
% space params T, Z, H, RQR as well as the initialisations of mean and
% covariance matrix of the state vector (s0, P0). Depending on the type of
% forecast, additional arguments are as follows:
% - unconditional forecasting: Y_f = NaN(Nn, Nh), Y_l, Y_u empty
% - conditional forecasting (hard conditions): Y_f partially observed, Y_l, Y_u empty
% - conditional forecasting (soft conditions): Y_f = NaN(Nn, Nh), Y_u (Y_l) 
%   are Nn x Nh matrix indicating the upper (lower) bound, may be partially
%   NaN where no restrictions are imposed. 
% Note that the "type" of forecast is inferred from the input arguments. In
% the case of soft conditioning, draws of Y_f are taken as often as
% required until the restrictions are satisfied. 
% Return arguments are a draw of the state vector and the forecasts (empty
% if Nh = 0).
%-------------------------------------------------------------------------%


% check args, infer forecast type
if isempty(Y_f) && isempty(Y_u) && isempty(Y_l)
    ftype = 'none';
elseif all(isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'unconditional';
elseif any(~isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'conditional (hard)';
elseif all(isnan(Y_f), 'all') && ~isempty(Y_u) && ~isempty(Y_l)
    ftype = 'conditional (soft)';
end

% back out dimensions
Ns = size(T, 1);
[Nn, Nt] = size(Y_o);
Nh = size(Y_f, 2);
Nobs = Nt + Nh; 

% empty matrices to store stuff
sdraw = NaN(Ns, Nobs);
Ydraw = Y_f;
stt = NaN(Ns,Nobs);
Ptt = NaN(Ns,Ns,Nobs);
stT = NaN(Ns,Nobs);
PtT = NaN(Ns,Ns,Nobs);

% forward recursions 
eye_N = eye(Nn); % 
Y = [Y_o, Y_f]; 

for t = 1:Nobs
    % predict!
    if t==1
        st = T*s0;
        Pt = T*P0*T' + RQR;
    else
        st = T*st;
        Pt = T*Pt*T' + RQR;
    end
    
    % update!
    if not(all(isnan(Y(:, t))))
        % check for missings 
        notmissing = ~isnan(Y(:,t));
        Wt = eye_N(notmissing,:);
        v = Y(notmissing, t) - Wt*Z * st;
        K = Pt * (Wt * Z)' / (Wt * Z * Pt * (Wt * Z)' + Wt * H * Wt');
        st = st + K * v;
        Pt = (eye(size(T, 1))- K * Wt * Z) * Pt; 
    end
    
    % store states and their covariance matrix
    stt(:,t) = st;   
    Ptt(:,:,t) = Pt;
end

% sample states and obs in t = Nobs
stT(:, t) = stt(:, t);
PtT(:, :, t) = Ptt(:, :, t);
if t > Nt
    if isempty(Y_l); y_l = [];else y_l = Y_l(:, t-Nt);end
    if isempty(Y_u); y_u = [];else y_u = Y_u(:, t-Nt);end
    [sdraw(:, t), Ydraw(:, t-Nt)] = draw_s_y(stT(:, t), PtT(:, :, t), Z, H, Y(:, t), y_u, y_l, ftype);
else
    %sdraw(:, t) = mvnrnd(stT(:, t), PtT(:, :, t));
    sdraw(:, t) = rue_held_alg2_3(stT(:, t), chol(PtT(:, :, t), 'lower'));
end
% if ~strcmp(ftype, 'none')
%     cholH = chol(H, 'lower');
%     cholP = chol(PtT(:, : , t), 'lower');
%     restr = 0; 
%     ind_o = isnan(Y(:, t));
%     if strcmp(ftype, 'conditional (soft)')
%         ind_r_u = ~isnan(Y_u(:, t-Nt));
%         ind_r_l = ~isnan(Y_l(:, t-Nt));
% 
%         while restr == 0
%             s_tmp = stT(:, t) + cholP' * randn(Ns, 1);
%             Ydraw_tmp = Z * s_tmp + cholH' * randn(Nn, 1);
%             if all(Ydraw_tmp(ind_r_l, 1) > Y_l(ind_r_l, 1)) && all(Ydraw_tmp(ind_r_u, 1) < Y_u(ind_r_u, 1))
%                 restr = 1;
%                 sdraw(:, t) = s_tmp; 
%                 Ydraw(ind_o, t-Nt) = Ydraw_tmp(ind_o, 1); 
%             end
%         end
%     elseif strcmp(ftype, 'unconditional') || strcmp(ftype, 'conditional (hard)') 
%        sdraw(:, t) = stT(:, t) + cholP' * randn(Ns, 1);
%        Ydraw_tmp = Z * sdraw(:, t) + cholH' * randn(Nn, 1); 
%        Ydraw(ind_o, t-Nt) = Ydraw_tmp(ind_o, 1); 
%     end
% else
%     sdraw(:, t) = mvnrnd(stT(:, t), PtT(:, :, t));
% end

% backward recursions 
for t=Nobs-1:-1:1
    % stT and PtT
    J = Ptt(:, :, t) * T'/(T*Ptt(:,:,t)*T' + RQR);
    stT(:,t) = stt(:,t) + J*(sdraw(:,t+1) - T*stt(:,t));
    PtT(:,:,t) = Ptt(:,:,t) + J*(PtT(:,:,t+1) - (T*Ptt(:,:,end)*T' + RQR))*J';  
    if t > Nt
        if isempty(Y_l); y_l = [];else y_l = Y_l(:, t-Nt);end
        if isempty(Y_u); y_u = [];else y_u = Y_u(:, t-Nt);end
        [sdraw(:, t), Ydraw(:, t-Nt)] = draw_s_y(stT(:, t), PtT(:, :, t), Z, H, Y(:, t), y_u, y_l, ftype);
    else
        sdraw(:, t) = rue_held_alg2_3(stT(:, t), chol(PtT(:, :, t), 'lower'));
    end
    % draw states and missing obs
%     if t > Nt
%     cholH = chol(H, 'lower');
%     cholP = chol(PtT(:, : , t), 'lower');
%     restr = 0; 
%     ind_o = isnan(Y(:, t)); 
%     ind_r_u = ~isnan(Y_u(:, t-Nt));
%     ind_r_l = ~isnan(Y_l(:, t-Nt));
%     while restr == 0
%         s_tmp = stT(:, t) + cholP' * randn(Ns, 1);
%         Ydraw_tmp = Z * s_tmp + cholH' * randn(Nn, 1);
%         if all(Ydraw_tmp(ind_r_l, 1) > Y_l(ind_r_l, 1)) && all(Ydraw_tmp(ind_r_u, 1) < Y_u(ind_r_u, 1))
%             restr = 1;
%             sdraw(:, t) = s_tmp;             
%             Ydraw(ind_o, t-Nt) = Ydraw_tmp(ind_o, 1); 
%         end
%     end
%     else
%         sdraw(:, t) = mvnrnd(stT(:, t), PtT(:, :, t));
%     end
end

function [sdraw, ydraw] = draw_s_y(s, P, Z, H, y, y_u, y_l, ftype)
cholH = chol(H, 'lower');
cholP = chol(P, 'lower');
restr = 0; 
ind_o = isnan(y);
ydraw = y; 
if strcmp(ftype, 'conditional (soft)')
    ind_r_u = ~isnan(y_u);
    ind_r_l = ~isnan(y_l);

    while restr == 0
        s_tmp = rue_held_alg2_3(s, cholP);
        ydraw_tmp = rue_held_alg2_3(Z * s_tmp, cholH);
        %ydraw_tmp = Z * s_tmp + cholH' * randn(Nn, 1);
        if all(ydraw_tmp(ind_r_l, 1) > y_l(ind_r_l, 1)) && all(ydraw_tmp(ind_r_u, 1) < y_u(ind_r_u, 1))
            restr = 1;
            sdraw = s_tmp; 
            ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
        end
    end
elseif strcmp(ftype, 'unconditional') || strcmp(ftype, 'conditional (hard)') 
   sdraw = rue_held_alg2_3(s, cholP);
   ydraw_tmp = rue_held_alg2_3(Z * sdraw, cholH);
   ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
end







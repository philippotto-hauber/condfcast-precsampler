function [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0, max_iter)
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
Ns = size(T, 1); % # of states 
[Nn, Nt] = size(Y_o); % # of variables and observations, respectively
Nh = size(Y_f, 2); % forecast horizon
NtNh = Nt + Nh; % # of total periods

% empty matrices to store stuff
sdraw = NaN(Ns, NtNh);
Ydraw = Y_f;
stt = NaN(Ns,NtNh);
Ptt = NaN(Ns,Ns,NtNh);
stT = NaN(Ns,NtNh);
PtT = NaN(Ns,Ns,NtNh);

% forward recursions 
eye_N = eye(Nn);  
Y = [Y_o, Y_f]; 
RQR = R * Q * R'; 
for t = 1:NtNh
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
    if isempty(Y_l); y_l = [];else; y_l = Y_l(:, t-Nt);end
    if isempty(Y_u); y_u = [];else; y_u = Y_u(:, t-Nt);end
    [sdraw(:, t), Ydraw(:, t-Nt)] = draw_s_y(stT(:, t), PtT(:, :, t), Z, H, Y(:, t), y_u, y_l, ftype, max_iter);
else
    sdraw(:, t) = rue_held_alg2_3(stT(:, t), chol(PtT(:, :, t), 'lower'));
end

% backward recursions 
for t=NtNh-1:-1:1
    % stT and PtT
    J = Ptt(:, :, t) * T'/(T*Ptt(:,:,t)*T' + RQR);
    stT(:,t) = stt(:,t) + J*(sdraw(:,t+1) - T*stt(:,t));
    PtT(:,:,t) = Ptt(:,:,t) + J*(PtT(:,:,t+1) - (T*Ptt(:,:,end)*T' + RQR))*J';  
    if t > Nt
        if isempty(Y_l); y_l = [];else; y_l = Y_l(:, t-Nt);end
        if isempty(Y_u); y_u = [];else; y_u = Y_u(:, t-Nt);end
        [sdraw(:, t), Ydraw(:, t-Nt)] = draw_s_y(stT(:, t), PtT(:, :, t), Z, H, Y(:, t), y_u, y_l, ftype, max_iter);
    else
        sdraw(:, t) = rue_held_alg2_3(stT(:, t), chol(PtT(:, :, t), 'lower'));
    end
end

function [sdraw, ydraw] = draw_s_y(s, P, Z, H, y, y_u, y_l, ftype, max_iter)
cholH = chol(H, 'lower');
cholP = chol(P, 'lower');
ind_o = isnan(y);
ydraw = y; 
if strcmp(ftype, 'conditional (soft)')
    ind_r_u = ~isnan(y_u);
    ind_r_l = ~isnan(y_l);
    iter = 0;
    while true
        % update iter and check limit
        iter = iter + 1; 
        if iter == max_iter
            error(['Did not obtain an acceptable draw in ' num2str(max_iter) ' attempts. Consider raising the limit or relaxing the restrictions.'])
        end
        s_tmp = rue_held_alg2_3(s, cholP);
        ydraw_tmp = rue_held_alg2_3(Z * s_tmp, cholH);
        if all(ydraw_tmp(ind_r_l, 1) > y_l(ind_r_l, 1)) && all(ydraw_tmp(ind_r_u, 1) < y_u(ind_r_u, 1))
            sdraw = s_tmp; 
            ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
            break;
        end
    end
elseif strcmp(ftype, 'unconditional') || strcmp(ftype, 'conditional (hard)') 
   sdraw = rue_held_alg2_3(s, cholP);
   ydraw_tmp = rue_held_alg2_3(Z * sdraw, cholH);
   ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
end







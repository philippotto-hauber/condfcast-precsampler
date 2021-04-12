function [adraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter)
% This code samples states and forecasts from a state space model of the
% following form: 
% y_t = Z alpha_t + e_t; e_t ~ N(0, H)
% s_t = T alpha_t-1 + R u_t; u_T ~ N(0, Q)
% using the Carter and Kohn (1994, Biometrika) algorithm. 
% See Kim and Nelson (1998) for a textbook treatment.
% Compared to standard implementations, this code can be applied for both
% unconditional and hard&soft conditional forecasting. 
% Depending on the type of forecast, arguments are as follows:
% - no forecast (standard simulation smoother): Y_o Nn x Nt matrix, Y_f, Y_u, Y_l empty
% - unconditional forecasting: Y_f = NaN(Nn, Nh), Y_l, Y_u empty
% - conditional forecasting (hard conditions): Y_f partially observed, Y_l, Y_u empty
% - conditional forecasting (soft conditions): Y_f = NaN(Nn, Nh), Y_u (Y_l) 
%   are Nn x Nh matrix indicating the upper (lower) bound, may be partially
%   NaN where no restrictions are imposed. 
% Note that the "type" of forecast is inferred from the input arguments. In
% the case of soft conditioning, draws of Y_f are taken until the restrictions
% are satisfied or max_iter is reached!
% Return arguments are a draw of the Nj x Nt+Nh state vectors where 1:Nj 
% correspond to the non-singular subblock of the state covariance matrix RQR (see Kim and Nelson 1999, 8.2)
% (inferred from the non-zero elements of R/ the dimensions of R and Q)
% as well as the Nn x Nh matrix of forecasts (empty if Nh = 0).
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
Nn = size(H, 1); % # of variables
Nt = size(Y_o, 2); % # of observations
Nh = size(Y_f, 2); % forecast horizon
NtNh = Nt + Nh; % # of total periods

% elements in state vector corresponding to non-singular submatrix of Q (see Kim and Nelson 1999, chapter 8.2)
Nj = sum(not(all(R == 0, 2))); % ind_j = size(Q, 1); 

% empty matrices to store stuff
adraw = NaN(Nj, NtNh);
Ydraw = Y_f;
att = NaN(Ns,NtNh);
Ptt = NaN(Ns,Ns,NtNh);

% forward recursions 
eye_N = eye(Nn);  
Y = [Y_o, Y_f]; 
RQR = R * Q * R'; 

a = a1; % E[alpha_1|y_0], see Hamilton (1994, p. 378)
P = P1; % E[(alpha_1 - E[a_1|y_0])(alpha_1 - E[a_1|y_0])'], see Hamilton (1994, p. 378)
for t = 1:NtNh    
    % update!
    if not(all(isnan(Y(:, t))))
        % check for missings 
        notmissing = ~isnan(Y(:,t));
        Wt = eye_N(notmissing,:);
        v = Y(notmissing, t) - Wt*Z * a;
        K = P * (Wt * Z)' / (Wt * Z * P * (Wt * Z)' + Wt * H * Wt');
        a = a + K * v; % E[alpha_t|y_t]
        P = (eye(size(T, 1))- K * Wt * Z) * P; 
    end
    
    % store states and their covariance matrix
    att(:,t) = a;   
    Ptt(:,:,t) = P;
    
    % predict!
    a = T*a; % E[alpha_t+1|y_t]
    P = T*P*T' + RQR;
end

% sample states and obs in t = Nobs
atT = att(:, t);
PtT = Ptt(:, :, t);
if t > Nt
    if isempty(Y_l); y_l = [];else; y_l = Y_l(:, t-Nt);end
    if isempty(Y_u); y_u = [];else; y_u = Y_u(:, t-Nt);end
    [adraw(:, t), Ydraw(:, t-Nt)] = draw_a_y(atT(1:Nj, 1), PtT(1:Nj, 1:Nj), Z(:, 1:Nj), H, Y(:, t), y_u, y_l, ftype, max_iter);
else % no forecasts
    adraw(:, t) = mvnrnd(atT(1:Nj, 1), PtT(1:Nj, 1:Nj))'; 
end

% backward recursions 
for t=NtNh-1:-1:1
    T_j = T(1:Nj, :); % F*, Kim and Nelson (1999, p. 196)
    RQR_j = RQR(1:Nj, 1:Nj); % == Q! Q* in Kim and Kim and Nelson (1999, p. 196)!
    % stT and PtT
    K_j = Ptt(:, :, t) * T_j' / (T_j * Ptt(:, :, t) * T_j' + RQR_j);  
    atT = att(:,t) + K_j *(adraw(:, t+1) - T_j * att(:,t)); % \beta_{t|t,\beta^*_{t+1}}, see Kim and Nelson (1999, eqn. 8.16')
    PtT = Ptt(:,:,t) - K_j * T_j * Ptt(:, :, t); % P_{t|t,\beta^*_{t+1}}, see Kim and Nelson (1999, eqn. 8.16')
    if t > Nt
        if isempty(Y_l); y_l = [];else; y_l = Y_l(:, t-Nt);end
        if isempty(Y_u); y_u = [];else; y_u = Y_u(:, t-Nt);end
        [adraw(:, t), Ydraw(:, t-Nt)] = draw_a_y(atT(1:Nj, 1), PtT(1:Nj, 1:Nj), Z(:, 1:Nj), H, Y(:, t), y_u, y_l, ftype, max_iter);
    else
        adraw(:, t) = rue_held_alg2_3(atT(1:Nj, 1), chol(PtT(1:Nj, 1:Nj), 'lower'));
    end
end

function [adraw, ydraw] = draw_a_y(a, P, Z, H, y, y_u, y_l, ftype, max_iter)
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
        a_tmp = mvnrnd(a, P)';
        ydraw_tmp = mvnrnd(Z * a_tmp, H)';
        if all(ydraw_tmp(ind_r_l, 1) > y_l(ind_r_l, 1)) && all(ydraw_tmp(ind_r_u, 1) < y_u(ind_r_u, 1))
            adraw = a_tmp; 
            ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
            break;
        end
    end
elseif strcmp(ftype, 'unconditional') || strcmp(ftype, 'conditional (hard)') 
   adraw = mvnrnd(a, P)';
   ydraw_tmp = mvnrnd(Z * adraw, H)';
   ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 
end







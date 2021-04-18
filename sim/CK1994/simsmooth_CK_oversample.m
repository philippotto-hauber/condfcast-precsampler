function store_Ydraw = simsmooth_CK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Ndraws)
%----------%

% back out dimensions
Ns = size(T, 1); % # of states 
Nn = size(H, 1); % # of variables
Nt = size(Y_o, 2); % # of observations
Nh = size(Y_f, 2); % forecast horizon
NtNh = Nt + Nh; % # of total periods

% elements in state vector corresponding to non-singular submatrix of Q (see Kim and Nelson 1999, chapter 8.2)
Nj = sum(not(all(R == 0, 2))); % ind_j = size(Q, 1); 

% empty matrices to store stuff
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

% sample Ndraws times
store_Ydraw = NaN(Nn, Nh, Ndraws);

for m = 1:Ndraws
    atT = att(:, t);
    PtT = Ptt(:, :, t);
    % sample states and obs in t = Nobs
    [adraw, Ydraw] = draw_a_y(atT(1:Nj, 1), PtT(1:Nj, 1:Nj), Z(:, 1:Nj), H, Y(:, t), y_u, y_l, ftype, max_iter);
    store_Ydraw(:, :, m) = Ydraw;
    
    % backward recursions 
    for t=NtNh-1:-1:Nt
        T_j = T(1:Nj, :); % F*, Kim and Nelson (1999, p. 196)
        RQR_j = RQR(1:Nj, 1:Nj); % == Q! Q* in Kim and Kim and Nelson (1999, p. 196)!
        % stT and PtT
        K_j = Ptt(:, :, t) * T_j' / (T_j * Ptt(:, :, t) * T_j' + RQR_j);  
        atT = att(:,t) + K_j *(adraw - T_j * att(:,t)); % \beta_{t|t,\beta^*_{t+1}}, see Kim and Nelson (1999, eqn. 8.16')
        PtT = Ptt(:,:,t) - K_j * T_j * Ptt(:, :, t); % P_{t|t,\beta^*_{t+1}}, see Kim and Nelson (1999, eqn. 8.16')
        [adraw, Ydraw] = draw_a_y(atT(1:Nj, 1), PtT(1:Nj, 1:Nj), Z(:, 1:Nj), H, Y(:, t), y_u, y_l, ftype, max_iter);
        store_Ydraw(:, :, m) = Ydraw;
    end
end

function [adraw, ydraw] = draw_a_y(a, P, Z, H, y)
ind_o = isnan(y);
ydraw = y; 
cholP = chol(P, 'lower');
adraw = rue_held_alg2_3(a, cholP);
ydraw_tmp = mvnrnd(Z * adraw, H)';
ydraw(ind_o, 1) = ydraw_tmp(ind_o, 1); 








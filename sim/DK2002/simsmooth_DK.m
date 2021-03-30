function [adraw, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1)
% This code samples states and forecasts from a state space model of the
% following form: 

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
ind_fore = isnan(Y_f);
Y = [Y_o, Y_f]; 

% case distinction
if strcmp(ftype, 'conditional (soft)')
    % ind
    ind_y_l = not(isnan(Y_l));
    ind_y_u = not(isnan(Y_u));
    % run Kalman smoother on data
    ahat = kalmansmoother(Y, T, Z, H, R, Q, a1, P1);
    
    % draw until conditions are satisfied 
    condition_satisfied = false;
    while not(condition_satisfied)    
        % draw from joint distribution of a and Y
        [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);

        % run Kalman smoother on simulated data
        aplushat = kalmansmoother(Yplus, T, Z, H, R, Q, a1, P1);

        % draw of a and Y_f
        adraw = ahat - aplushat + aplus ; % random draw of state vector
        Ydraw_tmp = Z * adraw(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh);

        % check conditions
        if all(Ydraw_tmp(ind_y_l) > Y_l(ind_y_l)) && all(Ydraw_tmp(ind_y_u) < Y_u(ind_y_u))
            condition_satisfied = true;
        end
    end
    
else
    % draw from joint distribution of a and Y
    [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
    Ystar = Y-Yplus;

    % run Kalman smoother
    ahatstar = kalmansmoother(Ystar, T, Z, H, R, Q, a1, P1);

    % draw a and Y_f
    adraw = ahatstar + aplus ; % random draw of state vector
    Ydraw_tmp = Z * adraw(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh);
end

% overwrite NaN's in Y_f with draws
Ydraw = Y_f;
Ydraw(ind_fore) = Ydraw_tmp(ind_fore); 
if any(isnan(Ydraw), 'all')
    error('There should be no NaN in return arg Ydraw!')
end

function [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn)
% generate unconditional draw from state vector
aplus = NaN(Ns, NtNh+1);
Yplus = NaN(Nn, NtNh);

aplus(:,1) = chol(P1) * randn(Ns, 1) + a1; % initial values of state
cholQ = chol(Q, 'lower') ;
cholH = chol(H, 'lower') ;

for t=1:NtNh
    Yplus(:, t) = Z * aplus(:, t)+ cholH * randn(size(Z, 1), 1);
    aplus(:, t+1) = T * aplus(:, t) + R * cholQ * randn(size(Q, 1), 1);
end

aplus(:,end) = [];

function ahatstar = kalmansmoother(Y, T, Z, H, R, Q, a1, P1)

[Nn, NtNh] = size(Y);
Ns = size(T, 1); 

% prepare Kalman filter
v = cell(NtNh, 1);
invF = cell(NtNh, 1);
L = NaN(Ns, Ns, NtNh);
a = a1;
P = P1;
eye_N = eye(Nn);
RQR = R*Q*R';

% forward recursions
for t=1:NtNh
    % check for missings 
    notmissing = ~isnan(Y(:,t));
    Wt = eye_N(notmissing,:);
    % proceed with recursions
    v{t,1} = Y(notmissing,t) - Wt*Z*a;
    F = Wt*Z*P*(Wt*Z)' + Wt*H*Wt';
    invF{t,1} = F\eye(size(F,1));
    K = T*P*(Wt*Z)'*invF{t,1};
    L(:,:,t) = T-K*Wt*Z; 
    a = T*a + K*v{t,1};
    P = T*P*L(:,:,t)'+RQR;
end

% prepare Kalman smoother to get r

r = NaN(size(T,1), NtNh);
r(:,end) = zeros(Ns, 1);

% backward recursion 
for t = (NtNh-1):-1:1
    % check for missings 
    notmissing = ~isnan(Y(:,t+1));
    Wt = eye_N(notmissing,:);
    r(:,t) = (Wt*Z)'*invF{t+1,1}*v{t+1,1}+L(:,:,t+1)'*r(:,t+1); 
end

% r0
notmissing = ~isnan(Y(:,1));
Wt = eye_N(notmissing,:);
r_0 = (Wt*Z)'*invF{1,1}*v{1,1}+L(:,:,1)'*r(:,1);


% forward recursions to get smoothed state alphahatstar
ahatstar = NaN(Ns, NtNh);
ahatstar(:, 1) = a1 + P1*r_0;

for t=2:NtNh
    ahatstar(:,t) = T*ahatstar(:,t-1) + RQR*r(:,t-1);
end


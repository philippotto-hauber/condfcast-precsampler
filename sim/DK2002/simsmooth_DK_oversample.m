function store_Ydraw = simsmooth_DK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Ndraws)
% ------------

% back out dimensions
Ns = size(T, 1); % # of states
Nn = size(Z, 1); % # of variables
Nt = size(Y_o, 2); % # of observations
Nh = size(Y_f, 2); % forecast horizon
NtNh = Nt + Nh; % # of total periods
ind_fore = isnan(Y_f);
Y = [Y_o, Y_f]; 

% sample Ndraws
store_Ydraw = NaN(Nn, Nh, Ndraws);

% first draw outside of loop
[aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
Ystar = Y-Yplus;

[ahatstar, K, L, invF] = kalmansmoother_storeKLinvF(Ystar, T, Z, H, R, Q, a1, P1);
adraw = ahatstar + aplus ; % random draw of state vector
Ydraw_tmp = Z * ahatstar(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh); % this one is correct

Ydraw = Y_f; % overwrite NaN's in Y_f with draws
Ydraw(ind_fore) = Ydraw_tmp(ind_fore); 
if any(isnan(Ydraw), 'all')
    error('There should be no NaN in return arg Ydraw!')
end
store_Ydraw(:, :, 1) = Ydraw; 

% loop 
for m = 2:Ndraws
    % draw from joint distribution of a and Y
    [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
    Ystar = Y-Yplus;

    % run Kalman smoother
    a1 = zeros(size(a1)); % set E[alpha_1|Ystar_0] to 0. See Jarocinski (2015)
    ahatstar = kalmansmoother(Ystar, T, Z, K, L, invF, R, Q, a1, P1);

    % draw a and Y_f
    adraw = ahatstar + aplus ; % random draw of state vector
    Ydraw_tmp = Z * ahatstar(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh); 

    % overwrite NaN's in Y_f with draws
    Ydraw = Y_f;
    Ydraw(ind_fore) = Ydraw_tmp(ind_fore); 
    if any(isnan(Ydraw), 'all')
        error('There should be no NaN in return arg Ydraw!')
    end
    store_Ydraw(:, :, m) = Ydraw; 
end

function [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn)
% generate unconditional draw from state vector
aplus = NaN(Ns, NtNh+1);
Yplus = NaN(Nn, NtNh);

if rcond(P1)==0
    aplus(:, 1) = a1;
else
    aplus(:,1) = mvnrnd(a1, P1)'; % initial values of state
end

cholQ = chol(Q, 'lower');
if rcond(H) == 0 % no measurement error
    for t=1:NtNh
        aplus(:, t+1) = T * aplus(:, t) + R * rue_held_alg2_3(zeros(size(Q, 1), 1), cholQ);
        Yplus(:, t) = Z * aplus(:, t);
    end
else
    cholH = chol(H, 'lower');
    for t=1:NtNh
        Yplus(:, t) = Z * aplus(:, t)+ rue_held_alg2_3(zeros(size(Z, 1), 1), cholH);
        aplus(:, t+1) = T * aplus(:, t) + R * rue_held_alg2_3(zeros(size(Q, 1), 1), cholQ);
    end
end

aplus(:,end) = [];

function [ahatstar, K, L, invF] = kalmansmoother_storeKLinvF(Y, T, Z, H, R, Q, a1, P1)

[Nn, NtNh] = size(Y);
Ns = size(T, 1); 

% prepare Kalman filter
v = cell(NtNh, 1);
invF = cell(NtNh, 1);
K = cell(NtNh, 1);
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
    K{t, 1} = T*P*(Wt*Z)'*invF{t,1};
    L(:,:,t) = T-K{t, 1}*Wt*Z; 
    a = T*a + K{t, 1}*v{t,1};
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

function ahatstar = kalmansmoother(Y, T, Z, K, L, invF, R, Q, a1, P1)

[Nn, NtNh] = size(Y);
Ns = size(T, 1); 

% prepare Kalman filter
v = cell(NtNh, 1);
a = a1;
eye_N = eye(Nn);
RQR = R*Q*R';

% forward recursions
for t=1:NtNh
    % check for missings 
    notmissing = ~isnan(Y(:,t));
    Wt = eye_N(notmissing,:);
    % proceed with recursions
    v{t,1} = Y(notmissing,t) - Wt*Z*a;
    a = T*a + K{t, 1}*v{t,1};
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


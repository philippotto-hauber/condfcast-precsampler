function [adraw, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter)
% This code samples states and forecasts from a state space model of the
% following form: 
% y_t = Z alpha_t + e_t; e_t ~ N(0, H)
% alpha_t = T alpha_t-1 + R u_t; u_T ~ N(0, Q)

% check args, infer forecast type
if isempty(Y_f) && isempty(Y_u) && isempty(Y_l)
    ftype = 'none';
elseif all(isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'unconditional';
elseif any(~isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'conditional (hard)';
%elseif all(isnan(Y_f), 'all') && ~isempty(Y_u) && ~isempty(Y_l)
elseif ~isempty(Y_u) && ~isempty(Y_l) % combine hard+soft conditions
    ftype = 'conditional (soft)';
end

% back out dimensions
Ns = size(T, 1); % # of states
Nn = size(Z, 1); % # of variables
Nt = size(Y_o, 2); % # of observations
Nh = size(Y_f, 2); % forecast horizon
NtNh = Nt + Nh; % # of total periods
ind_fore = isnan(Y_f);
Y = [Y_o, Y_f]; 

% case distinction
% Drawing a using the formula a = ahat - ahatplus + aplus does not produce
% a valid draw but just returns the mean!?
% if strcmp(ftype, 'conditional (soft)')
%     % ind upper and lower bound of restrictions
%     ind_y_l = not(isnan(Y_l));
%     ind_y_u = not(isnan(Y_u));
% 
%     % run Kalman smoother on data
%     ahat = kalmansmoother(Y, T, Z, H, R, Q, a1, P1);
% 
%     % draw until conditions are satisfied
%     iter = 0;
%     store_adraw = NaN(Nn, NtNh, max_iter);
%     while true
%         % update iter and check limit
%         iter = iter + 1;
%         if iter == max_iter
%             error(['Did not obtain an acceptable draw in ' num2str(max_iter) ' attempts. Consider raising the limit or relaxing the restrictions.'])
%         end
% 
%         % draw from joint distribution of a and Y
%         [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
% 
%         % run Kalman smoother on simulated data
%         aplushat = kalmansmoother(Yplus, T, Z, H, R, Q, a1, P1);
% 
%         % draw of a
%         adraw = ahat - aplushat + aplus ; % random draw of state vector
%         store_adraw(:, :, iter) = adraw(1:Nn, :); 
%         % draw of Y_f given a
%         % Y = Y^ - Yplus^ + Yplus
%         %   = Za^ - Z aplus^ + Yplus
%         %   = Z(a^ - aplus^) + Zaplus + e
%         %   = Zadraw + eps
%         Ydraw_tmp = Z * (ahat(:, Nt+1:NtNh) - aplushat(:, Nt+1:NtNh)) + Yplus(:, Nt+1:NtNh); % random draw of obs
% 
%         % check conditions
%         if all(Ydraw_tmp(ind_y_l) > Y_l(ind_y_l)) && all(Ydraw_tmp(ind_y_u) < Y_u(ind_y_u))
%             break; % conditions satisfied
%         end
%     end
if strcmp(ftype, 'conditional (soft)')
    % ind upper and lower bound of restrictions
    ind_y_l = not(isnan(Y_l));
    ind_y_u = not(isnan(Y_u));

    % draw until conditions are satisfied 
    iter = 0; 
    while true 
        % update iter and check limit
        iter = iter + 1; 
        if iter == max_iter
            error(['Did not obtain an acceptable draw in ' num2str(max_iter) ' attempts. Consider raising the limit or relaxing the restrictions.'])
        end
        
        % draw from joint distribution of a and Y
        [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
        Ystar = Y-Yplus;
        
        % run Kalman smoother => use a DIFFERENT smoother here that stores matrices for smoothing that do NOT change with yplus! 
        a1 = zeros(size(a1)); % set E[alpha_1|Ystar_0] to 0. See Jarocinski (2015)
        ahatstar = kalmansmoother(Ystar, T, Z, H, R, Q, a1, P1);

        % draw of a 
        adraw = ahatstar + aplus ; % random draw of state vector
        
        % draw of Y_f given a
        Ydraw_tmp = Z * ahatstar(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh); % this one is correct
       
        % check conditions
        if all(Ydraw_tmp(ind_y_l) > Y_l(ind_y_l)) && all(Ydraw_tmp(ind_y_u) < Y_u(ind_y_u))
            break; % conditions satisfied
        end
    end    
else
    % draw from joint distribution of a and Y
    [aplus, Yplus] = gen_aplusYplus(T, Z, H, R, Q, a1, P1, NtNh, Ns, Nn);
    Ystar = Y-Yplus;

    % run Kalman smoother
    a1 = zeros(size(a1)); % set E[alpha_1|Ystar_0] to 0. See Jarocinski (2015)
    ahatstar = kalmansmoother(Ystar, T, Z, H, R, Q, a1, P1);

    % draw a and Y_f
    adraw = ahatstar + aplus ; % random draw of state vector
    Ydraw_tmp = Z * ahatstar(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh); % this one is correct
    %Ydraw_tmp = Z * adraw(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh); % this formula is wrong
    %Ydraw_tmp = Z * adraw(:, Nt+1:NtNh) + Yplus(:, Nt+1:NtNh) - Z * aplus(:, Nt+1:NtNh); % this one is the same as above but more complicated
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

aplus(:,1) = mvnrnd(a1, P1)'; % initial values of state

for t=1:NtNh
    Yplus(:, t) = Z * aplus(:, t)+ mvnrnd(zeros(size(Z, 1), 1), H)';
    aplus(:, t+1) = T * aplus(:, t) + R * mvnrnd(zeros(size(Q, 1), 1), Q)';
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


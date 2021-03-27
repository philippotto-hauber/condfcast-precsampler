function [adraw, Ydraw] = simsmooth_CK(Y, T, Z, H, RQR, s0, P0)

% back out dimensions
Ns = size(T, 1);
[Nn, Nobs] = size(Y);

% empty matrices to store sampled states and obs
adraw = NaN(Ns, Nobs);
Ydraw = Y;

% forward recursions 
stt = NaN(Ns,Nobs);
Ptt = NaN(Ns,Ns,Nobs);
eye_N = eye(Nn);

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
adraw(:, t) = mvnrnd(stT(:, t), PtT(:, :, t));
Ydraw_tmp = mvnrnd(Z * adraw(:, t), H)';
Ydraw(isnan(Y(:, t)), t) = Ydraw_tmp(isnan(Y(:, t)), 1);

% backward recursions 
for t=Nobs-1:-1:1
    % stT and PtT
    J = Ptt(:, :, t) * T'/(T*Ptt(:,:,t)*T' + RQR);
    stT(:,t) = stt(:,t) + J*(stT(:,t+1) - T*stt(:,t));
    PtT(:,:,t) = Ptt(:,:,t) + J*(PtT(:,:,t+1) - (T*Ptt(:,:,end)*T' + RQR))*J';  
    % draw states and missing obs
    adraw(:, t) = mvnrnd(stT(:, t), PtT(:, :, t));
    Ydraw_tmp = mvnrnd(Z * adraw(:, t), H)';
    Ydraw(isnan(Y(:, t)), t) = Ydraw_tmp(isnan(Y(:, t)), 1);
end


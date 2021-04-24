function [T, Z, H, R, Q, a1, P1] = get_statespaceparams(params, y, model)

if strcmp(model, 'ssm')
    % generic state space model
    T = params.phi; 
    Z = params.lambda;
    H = diag(params.sig_eps);
    Q = params.sig_ups; 
    R = eye(size(T, 1)); 
    a1 = zeros(size(T, 1), 1); % E[alpha_1|y_0] = unconditional mean
    P1 = 10 * eye(size(T, 1)); % initialize with unconditional variance or diffusely!
elseif strcmp(model, 'var')
    % vector autoregression
    [T, R, Q] = var_companion(params.B, params.Sigma);
    Z = zeros(size(Q, 1), size(T, 2));
    Z(1:size(Q, 1), 1: size(Q, 1)) = eye(size(Q, 1));
    H = zeros(size(Q, 1)); %  1e-8 * eye(size(Q, 1))
    
    % a1 and P1
    Np = size(params.B, 2) / size(params.B, 1);
    a0 = y(:, end); 
    for p = 1:Np-1
        a0 = [a0; y(:, end-p)]; 
    end
    a1 = T * a0; % T * [y_T, y_T-1, ..., y_T-P+1]
    P1 = R*Q*R'; %
end
   


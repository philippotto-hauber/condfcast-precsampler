function [T, Z, H, R, Q, s0, P0] = get_statespaceparams(params, y, model)

if strcmp(model, 'ssm')
    % generic state space model
    T = params.phi; 
    Z = params.lambda;
    H = diag(params.sig_eps);
    Q = params.sig_ups; 
    R = eye(size(T, 1)); 
    s0 = zeros(size(T, 1), 1); 
    P0 = 1 * eye(size(T, 1));
elseif strcmp(model, 'var')
    % vector autoregression
    [T, R, Q] = var_companion(params.B, params.Sigma);
    Z = zeros(size(Q, 1), size(T, 2));
    Z(1:size(Q, 1), 1: size(Q, 1)) = eye(size(Q, 1));
    H = 1e-8 * eye(size(Q, 1)); % zeros(size(Q, 1))
    
    % s0 and P0
    Np = size(params.B, 2) / size(params.B, 1);
    s0 = y(:, end); 
    for p = 1:Np-1
        s0 = [s0; y(:, end-p)]; 
    end
    P0 = zeros(size(s0, 1)); % 1e-8 * eye(size(T, 1))  
end
   


function [T, Z, H, R, Q, s0, P0] = get_statespaceparams(simdata, model)

if strcmp(model, 'ssm')
    % generic state space model
    T = simdata.params.phi; 
    Z = simdata.params.lambda;
    H = diag(simdata.params.sig_eps);
    Q = simdata.params.sig_ups; 
    R = eye(size(T, 1)); 
    s0 = zeros(size(T, 1), 1); 
    P0 = 1 * eye(size(T, 1));
elseif strcmp(model, 'var')
    % vector autoregression
    [T, R, Q] = var_companion(simdata.params.B, simdata.params.Sigma);
    Z = zeros(size(Q, 1), size(T, 2));
    Z(1:size(Q, 1), 1: size(Q, 1)) = eye(size(Q, 1));
    H = zeros(size(Q, 1)); % 1e-8 * eye(size(Q, 1))
    s0 = zeros(size(T, 1), 1); % FIX LATER
    P0 = zeros(size(T, 1)); % 1e-8 * eye(size(T, 1))
end
   


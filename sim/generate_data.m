function simdata = generate_data(dims, model)
%-------------------------------------------------------------------------%
%- This code simulates data from a state space model, a dynamic factor
%- model or a vector autoregression, depending on the input argument model
%- model = {'ssm', 'dfm', 'var'}.
%- Inputs are model-dependent and stored in the structure dims. 
%- Output is a structure which is also model-dependent but always includes
%- the simulated data and forecasts as well as the parameters. 
%- See the Matlab LiveScript XXXX for details on the models
%-------------------------------------------------------------------------%

if strcmp(model, 'ssm')
    %-------------------------------------------------------------------- %
    %- state space model
    %-------------------------------------------------------------------- %
    
    % params
    T = 0.7 * eye(dims.Ns);
    Ssigma = eye(dims.Ns);
    tmp = uncondvar(T, Ssigma); Var_alpha = tmp(1:dims.Ns, 1:dims.Ns);
    F = sqrt(0.1)*randn(dims.Nn, dims.Ns) + 0.5;
    oomega = 0.5 * diag(F * Var_alpha * F');

    % loop over t
    y = NaN(dims.Nn, dims.Nt+dims.Nh);
    aalpha = NaN(dims.Ns, dims.Nt+dims.Nh);
    for t = 1:dims.Nt+dims.Nh
        if t == 1
            aalpha(:, t) = sqrt(Ssigma) * randn(dims.Ns, 1);         
        else
            aalpha(:, t) = T * aalpha(:, t-1) + sqrt(Ssigma) * randn(dims.Ns, 1);   
        end
        y(:, t) = F * aalpha(:, t) + oomega .* randn(dims.Nn, 1);
    end

    % store in structure
    simdata.y = y(:, 1:dims.Nt);
    simdata.yfore = y(:, dims.Nt+1:end);
    simdata.aalpha = aalpha;
    simdata.params.phi = T;
    simdata.params.psi = [];
    simdata.params.lambda = F;
    simdata.params.sig_eps = oomega;
    simdata.params.sig_ups = Ssigma; 

elseif strcmp(model, 'dfm')
    
elseif strcmp(model, 'var')
    
else
    error('Could not identify the model you selected. Please choose either ssm, dfm or var!')
end

%-----------------------------------------------------------------------%
%- This code simulates data from a state space model 
%- y_t = F aalpha_t + e_t; e_t ~ N(0, diag(oomega))
%_ aalpha_t = T aalpha_t-1 + u_t; u_t ~ N(0, Ssigma)
%_ Inputs are 
%_              - the number of observations (Nt),
%_              - the forecast horizon (Nh),
%_              - the number of states (Ns),
%_              - the number of variables (Nn).
%_ Output is a structure 
%-----------------------------------------------------------------------%


% Functions
function Sig = uncondvar(Phi, Omeg)
%- This function calculates the unconditional variance of the VAR:
%_ y_t = c + phi_1 y_t-1 + ... + phi_p y_t-p + e_t; e_t ~ N(0, Omeg).
%_ It is given by Sig = F * Sig * F' + Q, where F and Q are the companion
% form parameters of the VAR. See Hamilton (1994, pp. 264-265).
% Input: Nn x Nn*Np matrix of coefficients Phi = [phi1, ..., phi_p] 
%        Nn x Nn covariance matrix of VAR innovations
% Output: Nn*Np x Nn*Np unconditional covariance matrix Sig

% back out dims
Nn = size(Phi, 1);
Np = size(Phi, 2) / Nn; 

% companion form
F = [Phi zeros(Nn, (Np-1)*Nn); eye((Np-1)*Nn) zeros((Np-1)*Nn, Nn)]; 
Q = zeros(Nn*Np); Q(1:Nn, 1:Nn) = Omeg; 

% solve for Sig
A = kron(F, F); % eqn. 10.2.17
Sig = reshape((eye((Nn*Np)^2) - A) \ Q(:), Nn*Np, Nn*Np); % eqn. 10.2.18

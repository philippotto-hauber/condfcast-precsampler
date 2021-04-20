function generate_data(Ng)

if isdeployed
    Ng = str2double(Ng);
else
    dir_out = 'C:/Users/Philipp/Documents/Dissertation/condfcast-precsampler/sim/dgp/';
    addpath('./../functions')
end
    
rng(1234) % set random seed for reproducibility
Nhs = [5, 20, 50]; 
Nmodels = 1:6;

for Nh = Nhs
    for Nmodel = Nmodels
        [dims, model, dims_str] = get_dims(Nmodel, Nh, []);

        for g = 1:Ng
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
                % params
                [B, Sigma, F, ~] = sim_var_params(dims.Nn, dims.Np);

                % Cholesky of Sigma and R (needed for sampling innovations)
                cholSigma = chol(Sigma, 'lower');
                R = [eye(dims.Nn); zeros(size(F, 1) - dims.Nn, dims.Nn)];

                % burn-in
                Nburnin = 20; 

                % empty companion form vector to store simulated obs
                Y = zeros(size(F, 1), Nburnin+dims.Nt+dims.Nh);

                % loop over t
                for t = 2:Nburnin+dims.Nt+dims.Nh
                    Y(:, t) = F * Y(:, t-1) + R * rue_held_alg2_3(zeros(dims.Nn, 1), cholSigma);
                end

                % store in structure
                simdata.y = Y(1:dims.Nn, Nburnin+1:Nburnin+dims.Nt);
                simdata.yfore = Y(1:dims.Nn, Nburnin+dims.Nt+1:Nburnin+dims.Nt+dims.Nh);
                simdata.y0 = Y(1:dims.Nn, Nburnin-dims.Np+1:Nburnin);
                simdata.model = model;
                simdata.params.B = B;
                simdata.params.Sigma = Sigma; 
            else
                error('Could not identify the model you selected. Please choose either ssm, dfm or var!')
            end

            % save to file        
            filename = [model, '_', dims_str '_g_', num2str(g)];
            save([dir_out, filename, '.mat'], 'simdata');
        end
    end
end

    function [B, Sigma, F, Q] = sim_var_params(Nn, Np)

% set-up (see Cross et al. 2020, IJoF)
if Nn == 3
    sig_o = sqrt(0.6); % variance of b_1_ii
    sig_c = sqrt(0.2); % variance of b_p_ij, i \neq j
    p_c = 0.5; % inclusion probability of b_p_ij
elseif Nn == 20 % more shrinkage and sparsity
    sig_o = sqrt(0.2); % variance of b_1_ii
    sig_c = sqrt(0.05); % variance of b_p_ij, i \neq j
    p_c = 0.2; % inclusion probability of b_p_ij
elseif Nn == 100 % even more shrinkage and sparsity
    sig_o = sqrt(0.05);
    sig_c = sqrt(0.001);
    p_c = 0.1;
else 
    error('Nn needs to be equal to 3, 20 or 100')
end

while true
    b_1 = randn(Nn, 1) * sig_o;
    b = [b_1, b_1 ./ repmat(2:Np, Nn, 1)];
    B = [];

    for p = 1:Np
        Bp = diag(b(:, p)); 
        for i = 1:Nn
            for j = 1:Nn
                if i ~= j
                    if rand < p_c
                        Bp(i, j) = randn * sig_c;
                    end
                end
            end
        end
        B = [B, Bp];
    end

    Sigma = eye(Nn); 
    [F, Q] = var_companion(B, Sigma);
    if max(abs(eig(F))) < 1
        break
    end
end

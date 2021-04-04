clear; close all; 

addpath('./CK1994')
rng(1234) % set random seed for reproducibility
model = 'var'; 

dims.Nt = 50; % # of in-sample observations
dims.Nn = 100; % # of variables
dims.Np = 4; % # 
dims.Nh = 10; 


% params
[B, Sigma, F, Q] = sim_var_params(dims.Nn, dims.Np);

% loop over t
cholSigma = chol(Sigma, 'lower');
R = [eye(dims.Nn); zeros(size(F, 1) - dims.Nn, dims.Nn)];
Nburnin = 20; 
Y = zeros(size(F, 1), Nburnin+dims.Nt+dims.Nh);

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

figure; plot(simdata.y')

coefs_r = corrcoef(simdata.y');
figure; histogram(coefs_r(:))

figure; spy(simdata.params.B)

function [B, Sigma, F, R, Q] = sim_var_params(Nn, Np)

% set-up (see Cross et al. 2020, IJoF)
if Nn == 3
    sig_o = sqrt(0.6); % variance of b_1_ii
    sig_c = sqrt(0.2); % variance of b_p_ij, i \neq j
    p_c = 0.5; % inclusion probability of b_p_ij
elseif Nn == 25 % more shrinkage and sparsity
    sig_o = sqrt(0.2); % variance of b_1_ii
    sig_c = sqrt(0.05); % variance of b_p_ij, i \neq j
    p_c = 0.2; % inclusion probability of b_p_ij
elseif Nn == 100 % even more shrinkage and sparsity
    sig_o = sqrt(0.05);
    sig_c = sqrt(0.01);
    p_c = 0.05;
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
    [F, R, Q] = var_companion(B, Sigma);
    if max(abs(eig(F))) < 1
        break
    end
end
end


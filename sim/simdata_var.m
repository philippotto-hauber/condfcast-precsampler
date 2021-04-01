clear; close all; 

rng(1234) % set random seed for reproducibility

dims.Nt = 50; % # of in-sample observations
dims.Nn = 10; % # of variables
dims.Np = 3; % # 
dims.Nh = 10; 


% simulate params see Cross et al 2020
sig2_o = 0.1; 
sig2_c = 0.2;

Sigma = eye(dims.Nn); 
cholSigma = chol(Sigma, 'lower');

% loop over t
Nburnin = 20; 
y = zeros(dims.Nn, dims.Nt+dims.Nh);
for t = (dims.Np+1):Nburnin+dims.Nt+dims.Nh
    tmp = zeros(dims.Nn, 1); 
    for p = 1:dims.Np
        ind_B = (p-1)*dims.Nn+1:p*dims.Nn; 
        tmp = B(:, ind_B) * y(:, t-p);
    end
    y(:, t) = tmp + cholSigma *  randn(dims.Nn, 1);
end

% store in structure
simdata.y = y(:, Nburnin+1:Nburnin+dims.Nt);
simdata.yfore = y(:, Nburnin+dims.Nt+1:Nburnin+dims.Nt+dims.Nh);
simdata.y0 = y(:, Nburnin-dims.Np+1:Nburnin);
simdata.model = model;
simdata.params.B = B;
simdata.params.Sigma = [];  


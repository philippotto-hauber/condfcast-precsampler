function [f, Yplus] = f_sample_f_ymis(Y, phi, Omega, lam, psi, sig2, p_z)

% params
params.lambda = lam;
params.phi = phi;
params.psi = psi; 
params.sig_eps = sig2;
params.sig_ups = Omega; 

% vectorized yobs, removing missings
y = vec(Y'); 
yobs = y(~isnan(y),1); 
Nmis = sum(isnan(y)); % length(y) - Nobs;

NtNh = size(Y, 1);
Ns = size(Omega, 1); % # of factors
Nn = size(Y, 2); 

% precision matrix Q
[PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, NtNh, Nmis, p_z, 'ssm');

% joint draw of f, ymis
chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);
fxmis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis); 

z_draw(p_z, :) = [fxmis_draw; repmat(yobs, 1)]; % reverse permutation => z = [vec(f); vec([Y_o, Y_f])]!
f = reshape(z_draw(1:NtNh*Ns, :), Ns, NtNh)'; 
Yplus = reshape(z_draw(NtNh*Ns+1:end, :), Nn, NtNh)';


function hyperparams = f_update_hyperparams(hyperparams, lam, Nn, Nr)

% -- update hs_lam2 -- %
lam_vec = f_vec(lam);
mu_vec = f_vec(hyperparams.mu);
lam2_vec = 1./gamrnd(1,1./(1./mu_vec + 0.5*(lam_vec.^2)/hyperparams.tau2));
hyperparams.lam2 = reshape(lam2_vec,Nn,Nr);

% -- update hs_tau2 -- %
NnNr = Nn*Nr;
lam2_vec = f_vec(hyperparams.lam2);
tau2 = 1./gamrnd((NnNr+1)/2,1./(1./hyperparams.xi + 0.5*sum((lam_vec.^2)./lam2_vec)));

% -- update hs_xi -- %
hyperparams.xi = 1./gamrnd(1,1./(1+1/hyperparams.tau2));

% -- update hs_mu -- %
eta2_vec=f_vec(hyperparams.eta2);
mu_vec = 1./gamrnd(1,1./(1./eta2_vec+1./lam2_vec));
hyperparams.mu = reshape(mu_vec,Nn,Nr);

% -- update hs_eta2 -- %
z_vec=f_vec(hyperparams.z);
eta2_vec = 1./gamrnd(1,1./(1./mu_vec+1./z_vec));
hyperparams.eta2 = reshape(eta2_vec,Nn,Nr);

% -- update hs_z -- %
z_vec = 1./gamrnd(1,1./(1+1./eta2_vec));
hyperparams.z = reshape(z_vec,Nn,Nr);

function x = f_vec(X)
    %
    %
    [m, n] = size(X);
    x = reshape(X,m*n,1);


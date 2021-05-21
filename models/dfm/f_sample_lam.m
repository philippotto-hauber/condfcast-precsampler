function [lam, e] = f_sample_lam(y, f, sig2, psi, hyperparams, Ns)

Nn = size(y, 2);
Nr = size(f, 2);
Nj = size(psi, 2); 

lam2tau2inv = 1 ./ (hyperparams.lam2*hyperparams.tau2); % prior precision

X = f(Ns+1:end, :); % regressors
for s = 1:Ns
    X = [X f(Ns+1-s:end-s, :)];
end

Nobs = size(X, 1);

lam = NaN(Nn, (Ns+1)*Nr);
e = NaN(Nobs, Nn); 
for i = 1:Nn
    H_e = speye(Nobs);
    for j = 1:Nj
        H_e = H_e - spdiags(ones(Nobs,1)*psi(i, j), -j, Nobs, Nobs);
    end
    Q_e = H_e * kron(speye(Nobs), sig2(i,1)^(-1))*H_e';
    
    [lam_tmp, e_tmp] = f_linreg(y(Ns+1:end, i), X, Q_e, lam2tau2inv(i, :));
    
    lam(i, :) = lam_tmp';
    e(:, i) = e_tmp;
end
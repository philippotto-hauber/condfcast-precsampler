function [psi, eps] = f_sample_psi(e, psi, sig2, Nj, q0_psi)

eps = NaN(size(e, 1) - Nj, size(e, 2));
for i = 1:size(e,2)
    y = e(Nj+1:end, i);
    
    X = [];
    for j = 1:Nj
        X = [X e(Nj+1-j:end-j, i)];
    end
    
    Nobs = size(X, 1);
    
    Q_eps = speye(Nobs) *(sig2(i,1)^(-1)); 

    [psi_tmp, eps(:, i)] = f_linreg(y, X, Q_eps, q0_psi);
    psi(i, :) = psi_tmp';
end


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

    %[psi_tmp, eps(:, i)] = f_linreg(y, X, Q_eps, q0_psi);
    if Nj == 1
        XtQ_eps = X' * Q_eps;
        Q_psi = diag(q0_psi) + XtQ_eps * X;
        m_psi = Q_psi \ (XtQ_eps * y);

        psi(i, :) = f_sample_truncNorm(m_psi, sqrt(Q_psi^(-1)), -0.99, 0.99); % univariate Normal truncated to stationary region
        eps(:, i) = y - X * psi(i, :);
    else
        error('Nj>1 is not supported. Abort!')
    end
end


function [phi, Omega] = f_sample_phi(f, Np, Omega, q0_phi)

Nr = size(f, 2); 
[y, X] = f_constructyandX(f, Np);
Nobs = size(y, 1) / Nr;
Q_e = kron(speye(Nobs), eye(size(Omega, 1))/Omega);

max_iter = 100;
for iter = 1:max_iter
    [phi_vec, ~] = f_linreg(y, X, Q_e, q0_phi);
    phi_candidate = reshape(phi_vec, Nr*Np, Nr)';
    phi_companion = [phi_candidate; eye(Nr*(Np-1)) zeros(Nr*(Np-1), Nr)];

    if max(abs(eig(phi_companion))) < 1
        phi = phi_candidate;
        break
    end
end

if iter == max_iter
    error('Did not produce a stationary draw of phi!')
end



function [y_estim, X_estim] = f_constructyandX(y, Np)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the regressand and regressors of Np-dimensional VAR
% of the form y = X * theta + e
%
% INPUTS: y - Nt x Nn matrix of observations
%         Np - lag length of VAR
% OUTPUT: y_estim - Nn * (Nt-Np) x 1 matrix of vectorized regressands => vec([y_Np+1 ... y_Nt])
%         X_estim - regressor matrix of dimensions Nn * (Nt-Np) x
%         Nn^2*Np + Nn => kron( I_Nn , [1 y_t-1' ... y_t-Np'] ) stacked over Nt-Np periods
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------
% - get dimensions
% ------------------
[Nt, Nn] = size(y);

% ------------------
% - y_estim => vectorized y
% ------------------

y_estim = reshape(y(Np+1 : Nt, :)', Nn * (Nt-Np), 1); 

% ------------------
% - X_estim 
% ------------------
X_estim = [] ; 

for t = Np + 1 : Nt
    % X
    ylags = [] ; 
    for p = 1 : Np
        ylags = [ylags y(t-p, :)]; 
    end

    Xtemp = kron(speye(Nn), ylags);

    X_estim = [X_estim; Xtemp]; 
end




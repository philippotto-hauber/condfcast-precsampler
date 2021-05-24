function [lam, phi, psi, sig2] = f_startingvalues(y, options)

% factors
y(isnan(y)) = 0;
f_hat = f_pca(y', options.Nr)';

% lam
X_estim = f_hat(options.Ns+1:end, :);

for s = 1:options.Ns
    X_estim = [X_estim f_hat(options.Ns+1-s:end-s, :)];
end

y_estim = y(options.Ns+1:end, :); 
lam = ((X_estim'*X_estim)\X_estim'*y_estim)';
e = y_estim - X_estim * lam';

% phi
X_estim = [];

for p = 1:options.Np
    X_estim = [X_estim f_hat(options.Np+1-p:end-p, :)];
end

y_estim = f_hat(options.Np+1:end, :);
phi = ((X_estim'*X_estim)\X_estim'*y_estim)';

% psi
if options.Nj > 0
    psi = NaN(options.Nn, options.Nj);
    eps = NaN(size(e, 1) - options.Nj, options.Nn);
    for i = 1:options.Nn
        X_estim =  [];
        for j = 1:options.Nj
            X_estim = [X_estim e(options.Nj+1-j:end-j, i)];
        end
        y_estim = e(options.Nj+1:end, i);
        psi(i, :) = ((X_estim'*X_estim)\X_estim'*y_estim)';
        eps(:, i) = y_estim - X_estim * psi(i, :)';
    end
    sig2 = var(eps, [], 1)';
else
    psi = [];
    sig2 = var(e, [], 1)';
end


function F_hat = f_pca(Y,R)
% covariance matrix of observables
SIGMA = Y*Y'/size(Y,2);

% eigenvalue and -vector decomposition
[V,D] = eig(SIGMA);

% extract eigenvalues and change order
eigenvalues_D = diag(D);
eigenvalues_D = flipud(eigenvalues_D);
D = diag(eigenvalues_D);
% change order of eigenvectors
V = f_reversecolumns(V);
F_hat = V(:,1:R)'*Y ;

function [ A_reverse ] = f_reversecolumns( A )
%Reverses the columns of a matrix. 
aux = zeros(size(A));
[R,C] = size(A);
for c=0:(C-1);
    aux(:,c+1) = A(:,C-c);
end
A_reverse = aux;


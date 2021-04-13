function x = rue_held_alg2_3(m, L)
% function to implement algorithm 2.3 in Rue and Held (2005, p. 34)
% Sampling x ~ N(b, Sigma)
% Input:            L - NxN matrix, lower Cholesky factor of Sigma, i.e. L = chol(Sigma, 'lower')
%                   b - Nx1 vector, mean of the Normal
% Output:           x - Nx1 vector, draw from N(b,Sigma)
if ~istril(L)
   error('L needs to be the lower Cholesky factor!')
end
z = randn(size(m, 1), 1);
v = L * z;
x = m + v; 
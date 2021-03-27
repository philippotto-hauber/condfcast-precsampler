function x = rue_held_alg2_4(L, m)
% function to implement algorithm 2.4 in Rue and Held (2005, p. 34)
% Sampling x ~ N(b, Q^{-1})
% Input:            L - NxN matrix, lower Cholesky factor of Q, i.e. L = chol(Q, 'lower')
%                   b - Nx1 vector, mean of the Normal
% Output:           x - Nx1 vector, draw from N(b,Q^{-1})
if ~istril(L)
    error('L needs to be the lower Cholesky factor!')
end
z = randn(size(m, 1), 1);
v = L' \ z;
x = m + v;
end


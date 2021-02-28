function x = rue_held_alg2_1(L, b)
% function to implement algorithm 2.1 in Rue and Held (2005, p. 32)
% Solving Ax = b
% Input:            L - NxN matrix, lower Cholesky factor of A, i.e. L = chol(A, 'lower')
%                   b - Nx1 vector
% Output:           x - Nx1 vector, solution to the system of equations Ax = b
v = L \ b;
x = L' \ v;
end


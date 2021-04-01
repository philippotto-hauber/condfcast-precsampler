clear; close all; 
% This code compares different ways of reversing a permutation
% i) using the original permutation index p on the left-hand side 
% ii) i) but with preallocation
% iii) using the reverse index r(p) = 1:length(p)

N = 1000; % size of matrix
 
% generate sparse matrix and permutation index
A = sprandn(N,N,0.2);
p = randperm(N);
r(p) = 1:N;

% permute
PAP = A(p, p); 

% reverse permutation
tic;
Acheck_p(p, p) = PAP;
%all(Acheck_p == A, 'all')
telapsed_p = toc;

tic;
Acheck_p_alloc = spalloc(N, N, nnz(PAP)); 
Acheck_p_alloc(p, p) = PAP;
all(Acheck_p_alloc == A, 'all')
telapsed_p_alloc = toc;

tic
Acheck_r = PAP(r, r); 
%all(Acheck_r == A, 'all')
telapsed_r= toc;

disp('computing time of ii) and iii) relative to i)')
[telapsed_p; telapsed_p_alloc; telapsed_r] ./ telapsed_p


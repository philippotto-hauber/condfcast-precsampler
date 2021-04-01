clear;

N = 10000;
A = sprandn(N,N,0.2);

p = randperm(N);

r(p) = 1:N;

PAP = A(p, p); 

tic
Acheck_p(p, p) = PAP;
all(Acheck_p == A, 'all')
toc

% with prealloc
tic
Acheck_p_prealloc = spalloc(N, N, nnz(PAP)); 
Acheck_p_prealloc(p, p) = PAP;
all(Acheck_p_prealloc == A, 'all')
toc


tic
Acheck_r = PAP(r, r); 
all(Acheck_r == A, 'all')
toc


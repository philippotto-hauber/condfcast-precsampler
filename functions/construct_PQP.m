function [PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, Nt, Nmis, p_z, model)

if strcmp(model, 'ssm')
% back out dims
Nr = size(params.phi, 1);
Np = size(params.phi, 2) / Nr;
Nn = size(params.lambda, 1);
Ns = size(params.lambda, 2) / Nr - 1;
Nj = size(params.psi, 2);
NrNt = Nr*Nt;

% Llambda
Llambda = kron(speye(Nt), params.lambda(:, 1:Nr));

for s = 1:Ns
    tmp = spdiags(ones(Nt,1), -s, Nt, Nt);
    Llambda = Llambda + kron(tmp, params.lambda(:, Nr*s+1:Nr*(s+1)));
end

% Q_eps and H_e
Q_eps = kron(speye(Nt), eye(Nn) / diag(params.sig_eps)); 
H_e = speye(Nt*Nn);

for j = 1:Nj
    tmp = spdiags(ones(Nt,1), -j, Nt, Nt);
    H_e = H_e + kron(tmp, -diag(params.psi(:, j)));
end

% Q_ups and H_f
Q_ups = kron(speye(Nt), params.sig_ups \ eye(Nr));

H_f = speye(Nt*Nr);
for p = 1:Np
    tmp = spdiags(ones(Nt,1), -p, Nt, Nt);
    H_f = H_f + kron(tmp, -params.phi(:, (p-1)*Nr+1:p*Nr));
end

% blocks of Q
Q_y = H_e' * Q_eps * H_e;
Llambda_Q_y = Llambda' * Q_y;
Q_f = H_f' * Q_ups * H_f + Llambda_Q_y * Llambda; 
Q_f_y = -Llambda_Q_y; 
Q = vertcat(horzcat(Q_f, Q_f_y),horzcat(Q_f_y', Q_y)); % [[Q_f, Q_f_y]; [Q_f_y', Q_y]]

% permute Q
%dimQ = size(Q, 1);
%PQP = spalloc(dimQ, dimQ, nnz(Q));
PQP = Q(p_z, p_z); 
PQP_fymis = PQP(1:(NrNt + Nmis), 1:(NrNt + Nmis));
PQP_fymis_yobs = PQP(1:(NrNt + Nmis),NrNt + Nmis + 1 : end); 

elseif strcmp(model, 'var')
    % back out dims
    Nn = size(params.B, 1);
    Np = size(params.B, 2) / Nn;
    
    % H and Q
    H = speye(Nt*Nn);
    for p = 1:Np
        tmp = spdiags(ones(Nt,1), -p, Nt, Nt);
        H = H + kron(tmp, -params.B(:, (p-1)*Nn+1:p*Nn));
    end
    
    Q = H' * kron(speye(Nt), params.Sigma \ eye(Nn)) * H; 
    
    % permute Q
    PQP = Q(p_z, p_z); 
    PQP_fymis = PQP(1:Nmis, 1:Nmis);
    PQP_fymis_yobs = PQP(1:Nmis, Nmis + 1 : end);     
else
    error('model needs to be either ssm or var!')
end

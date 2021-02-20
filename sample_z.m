function [fdraw, Ydraw] = sample_z(Y, params, p_z)

[Nn, Nt] = size(Y);
Nmis = sum(sum(isnan(Y)));
Nr = size(params.phi, 1);

% precision matrix Q
[PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, Nt, Nmis, p_z);

% vectorized yobs, removing missings
y = Y(:); 
yobs = y(~isnan(y),1); 

% joint draw of f, ymis
chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
w = chol_PQP_fymis  \ (-PQP_fymis_yobs * yobs); 
b_fymis = chol_PQP_fymis' \ w; 
fxmis_draw = b_fymis + chol_PQP_fymis' \ randn(Nt * Nr + Nmis, 1); 

% reverse permutation
z_draw(p_z,:) = [fxmis_draw; repmat(yobs, 1)];
fdraw = reshape(z_draw(1:Nt*Nr, :), Nr, Nt); 
Ydraw = reshape(z_draw(Nt*Nr+1:end, :), Nn, Nt);



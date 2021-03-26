function [fdraw, Ydraw] = sample_z_softcond(Y, Nh, Y_l, Y_u, params, p_z)

[Nn, Nt] = size(Y);
Nr = size(params.phi, 1);

% vectorized restrictions
%y_l = vec([Y, Y_l]);
%y_u = vec([Y, Y_u]);
y_l = vec([NaN(size(Y)), Y_l]);
ind_l = ~isnan(y_l);
y_u = vec([NaN(size(Y)), Y_u]);
ind_u = ~isnan(y_u);

% vectorized yobs, removing missings
y = vec([Y, NaN(Nn, Nh)]); 
yobs = y(~isnan(y),1); 
Nmis = sum(sum(isnan([Y, NaN(Nn, Nh)])));

% precision matrix Q
[PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, Nt+Nh, Nmis, p_z);

% joint draw of f, ymis
chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);
restr = 0;
max_iter = 10000; 
iter = 0;
z_draw = NaN(size(b_fymis, 1), 1);
while restr == 0 && iter <= max_iter
    % update iter
    iter = iter + 1; 
    % draw candidate
    fxmis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis);
    % reverse permutation and back out y
    z_draw(p_z,1) = [fxmis_draw; repmat(yobs, 1)];
    y_draw = z_draw((Nt+Nh)*Nr+1:end, 1); % second dim should be 1, no? 
    % check soft conditions
    if all(y_draw(ind_l, 1) > y_l(ind_l, 1) & y_draw(ind_u, 1) < y_u(ind_u, 1))
        restr = 1;
    end
end

disp(iter)

% reshape draw of z
fdraw = reshape(z_draw(1:(Nt+Nh)*Nr, :), Nr, Nt+Nh); 
Ydraw = reshape(z_draw((Nt+Nh)*Nr+1:end, :), Nn, Nt+Nh);
end

function a = vec(A)
a = A(:); 
end


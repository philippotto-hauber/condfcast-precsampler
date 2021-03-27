function [fdraw, Y_f_draw] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, params, p_z)

% check args, infer forecast type
if isempty(Y_f) && isempty(Y_u) && isempty(Y_l)
    ftype = 'none';
elseif all(isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'unconditional';
elseif any(~isnan(Y_f), 'all') && isempty(Y_u) && isempty(Y_l)
    ftype = 'conditional (hard)';
elseif all(isnan(Y_f), 'all') && ~isempty(Y_u) && ~isempty(Y_l)
    ftype = 'conditional (soft)';
end

% back out dims
[Nn, Nt] = size(Y_o);
Nh = size(Y_f);
Nobs = Nt + Nh; 
Nr = size(params.phi, 1);

% vectorized restrictions
y_l = vec([NaN(size(Y_o)), Y_l]);
ind_l = ~isnan(y_l);
y_u = vec([NaN(size(Y_o)), Y_u]);
ind_u = ~isnan(y_u);

% vectorized yobs, removing missings
y = vec([Y_o, Y_f]); 
yobs = y(~isnan(y),1); 
Nmis = sum(isnan(y));

% precision matrix Q
[PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, Nobs, Nmis, p_z);

% joint draw of f, ymis
chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);
restr = 0;
iter = 0;
z_draw = NaN(size(b_fymis, 1), 1);
while restr == 0
    % update iter
    iter = iter + 1; 
    % draw candidate
    fxmis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis);
    % reverse permutation and back out y
    z_draw(p_z,1) = [fxmis_draw; repmat(yobs, 1)];
    y_draw = z_draw(Nobs*Nr+1:end, 1); % second dim should be 1, no? 
    % check soft conditions
    if all(y_draw(ind_l, 1) > y_l(ind_l, 1) & y_draw(ind_u, 1) < y_u(ind_u, 1))
        restr = 1;
    end
end

% reshape draw of z
fdraw = reshape(z_draw(1:Nobs*Nr, :), Nr, Nobs); 
Ydraw = reshape(z_draw(Nobs*Nr+1:end, :), Nn, Nobs);
Y_f_draw = Ydraw(:, Nt+1:Nobs);

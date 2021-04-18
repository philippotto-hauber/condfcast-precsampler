function store_Ydraw = simsmooth_HS_oversample(Y_o, Y_f, params, p_z, Ndraws, model)
% ----------------------------------------------------------------------- %

% back out number of vars, periods and forecast horizon
if isempty(Y_o)
    [Nn, Nh] = size(Y_f);
    Nt = 0;
else
    [Nn, Nt] = size(Y_o);
    Nh = size(Y_f, 2);
end

NtNh = Nt + Nh; % # of total periods
if strcmp(model, 'var')
    Ns = 0;
else
    Ns = size(params.phi, 1); % # of states
end

% vectorized yobs, removing missings
y = vec([Y_o, Y_f]); 
yobs = y(~isnan(y),1); 
Nmis = sum(isnan(y)); % length(y) - Nobs;
Nobs = sum(~isnan(y)); % length(yobs)

% precision matrix Q
[PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, NtNh, Nmis, p_z, model);

% joint draw of f, ymis
chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);

% sample Ndraws times from the posterior and store draws
store_Ydraw = NaN(Nn, Nh, Ndraws);
z_draw = NaN(length(p_z), 1); % Nmis+Nobs
for m = 1 : Ndraws
    fxmis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis); % draw f, xmis jointly     
    % reshape draw of z and back out return args
    z_draw(p_z, 1) = [fxmis_draw; repmat(yobs, 1)]; % reverse permutation => z = [vec(f); vec([Y_o, Y_f])]!
    if strcmp(model, 'var')
        Ydraw = reshape(z_draw, Nn, NtNh);
    else
        Ydraw = reshape(z_draw(NtNh*Ns+1:end, :), Nn, NtNh);
    end
    store_Ydraw(:, :, m) = Ydraw(:, Nt+1:NtNh); % only return forecasts, not entire Y!
end





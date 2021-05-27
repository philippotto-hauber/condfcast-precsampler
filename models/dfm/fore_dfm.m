function fore_dfm(n_spec)

if isdeployed
	n_spec = str2double(n_spec);
	maxNumCompThreads(1);
end


dir_in = 'draws/';
dir_out = 'forecasts/';
% vintage and forecast type
[v, model_spec, forecast_type] = get_specs_fore(n_spec);

% load estim output
load([dir_in, 'out_dfm_', model_spec, '_', v, '.mat']);

if strcmp(forecast_type, 'unconditional')
% unconditional forecasts
y_o = out_dfm.y_o;
y_f = NaN(size(out_dfm.y_c));
Ndraws = size(out_dfm.draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
store_Y_fore = NaN(Nh * Ndraws, Nn);
for m = 1:Ndraws
    [~, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore(Nh*(m-1)+1:Nh*m, :) = Yplus(end-Nh+1:end, :);    
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

elseif strcmp(forecast_type, 'conditional (hard)')
% conditional forecasts
y_o = out_dfm.y_o;
y_f = out_dfm.y_c;
Ndraws = size(out_dfm.draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
store_Y_fore = NaN(Nh * Ndraws, Nn);
for m = 1:Ndraws
    [~, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore(Nh*(m-1)+1:Nh*m, :) = Yplus(end-size(y_f, 1)+1:end, :);    
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

elseif strcmp(forecast_type, 'conditional (soft)')
% soft conditioning
y_o = out_dfm.y_o;
y_f = NaN(size(out_dfm.y_c));
Ndraws = size(out_dfm.draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
y_l = out_dfm.y_l;
y_u = out_dfm.y_u;
ind_cond = not(isnan(y_l));
store_Y_fore = NaN(Nh * Ndraws, Nn);
Nsample = 1000;
m = 1;
iter_max = 10000;
iter = 1;
while m < Ndraws && iter < iter_max
    [~, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, Nsample);
    % check conditions    
    for m1 = 1:Nsample
        Yplus_tmp = Yplus(end-size(y_f, 1)+1:end, :, m1); 
        check_u = Yplus_tmp(ind_cond) < y_u(ind_cond);
        check_l= Yplus_tmp(ind_cond) > y_l(ind_cond);
        if  all(check_u) && all(check_l)
            store_Y_fore(Nh*(m-1)+1:Nh*m, :) = Yplus_tmp;
            m = m + 1;
        end
    end
    iter = iter + 1; 
end

if iter == iter_max
    error('Soft conditioning took too many iterations. Abort')
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;
end

% export to csv
out_fore = [count_hs, count_draws, store_Y_fore];
writetable(array2table(out_fore, 'VariableNames',[{'horizon', 'draw'}, out_dfm.mnemonics]), [dir_out,  forecast_type, '_', model_spec, v '.csv'])



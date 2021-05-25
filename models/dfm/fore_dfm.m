function fore_dfm(spec)

addpath('../../functions')
dir_in = 'C:\Users\Philipp\Documents\Dissertation\condfcast-precsampler\models\dfm\';
dir_out = '';
% vintage and forecast type
[v, forecast_type] = get_v_forecast_type(spec);

% load estim output
load([dir_in, 'out_dfm_', v, '.mat']);


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
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore(Nh*(m-1)+1:Nh*m, :) = Yplus(end-Nh+1:end, :);    
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

% export to csv
out_fore = [count_hs, count_draws, store_Y_fore];
writetable(array2table(out_fore, 'VariableNames',[{'horizon', 'draw'}, out_dfm.mnemonics]), [dir_out 'uncond_' v '.csv'])


elseif strcmp(forecast_type, 'conditional (hard)')
% conditional forecasts
y_o = out_dfm.y_o;
y_f = out_dfm.y_c;
Ndraws = size(out_dfm.draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
store_Y_fore = NaN(Nh * Ndraws, Nn);for m = 1:size(out_dfm.draws.lam, 3)
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore(:, :, m) = Yplus(end-size(y_f, 1)+1:end, :);    
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

% export to csv
out_fore = [count_hs, count_draws, store_Y_fore];
writetable(array2table(out_fore, 'VariableNames',[{'horizon', 'draw'}, out_dfm.mnemonics]), [ dir_out 'hardcond_' v '.csv'])

elseif strcmp(forecast_type, 'conditional (soft)')
% soft conditioning
y_o = out_dfm.y_o;
y_f = NaN(size(out_dfm.y_c));
Ndraws = size(out_dfm.draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', Nr);
y_l = out_dfm.y_l;
y_u = out_dfm.y_u;
ind_cond = not(isnan(y_l));
store_Y_fore_c_soft = NaN(size(y_f, 1), size(y_o, 2), size(out_dfm.draws.lam, 3));
Nsample = 1000;
counter = 1;
iter_max = 10000;
iter = 1;
while counter < Ndraws && iter < iter_max
    disp(counter)
    [~, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, Nsample);
    % check conditions    
    for m1 = 1:Nsample
        Yplus_tmp = Yplus(end-size(y_f, 1)+1:end, :, m1); 
        check_u = Yplus_tmp(ind_cond) < y_u(ind_cond);
        check_l= Yplus_tmp(ind_cond) > y_l(ind_cond);
        if  all(check_u) && all(check_l)
            store_Y_fore_c_soft(:, :, counter) = Yplus_tmp;
            counter = counter + 1;
        end
    end
    iter = iter + 1; 
end

count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

% export to csv
out_fore = [count_hs, count_draws, store_Y_fore];
writetable(array2table(out_fore, 'VariableNames',[{'horizon', 'draw'}, out_dfm.mnemonics]), [dir_out 'softcond_' v '.csv'])
end


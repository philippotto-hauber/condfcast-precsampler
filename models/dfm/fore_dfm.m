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

%count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_hs = repmat(out_dfm.dates_fore, Ndraws);
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;

elseif strcmp(forecast_type, 'conditional_hard')
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

%count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_hs = repmat(out_dfm.dates_fore, Ndraws);
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
iter_max = 50000;
iter = 1;
while m < Ndraws && iter < iter_max
    disp(m)
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
    mess = ['Soft conditioning took too many iterations. After ' num2str(iter) , 'only ' num2str(m) ' acceptable draws were obtained. Abort!'];
    error(mess)    
end

%count_hs = kron(ones(Ndraws, 1), (1:Nh)');
count_hs = repmat(out_dfm.dates_fore, Ndraws);
count_draws = kron((1:Ndraws)', ones(Nh, 1));
% restandardize
store_Y_fore = store_Y_fore .* out_dfm.std_y_o + out_dfm.mean_y_o;
end

% export to csv
fid=fopen([dir_out,  forecast_type, '_', model_spec, '_', v '.csv'], 'w');
fprintf(fid,'%s, %s, ', 'quarter', 'draw');
for n = 1:size(store_Y_fore, 2)
    if n == size(store_Y_fore, 2)
        fprintf(fid,'%s',out_dfm.mnemonics{n});
    else
        fprintf(fid,'%s, ',out_dfm.mnemonics{n});
    end
end

fprintf(fid,'\r\n');
for m = 1:Ndraws
    tmp_str = count_hs{m,1}; 
    fprintf(fid,'%s, %d, ', tmp_str, count_draws(m));
    for n = 1:size(store_Y_fore, 2)
        if n == size(store_Y_fore, 2)
            fprintf(fid,'%2.4f',store_Y_fore(m, n));
        else
            fprintf(fid,'%2.4f, ',store_Y_fore(m, n));
        end
    end
    fprintf(fid,'\r\n');
end
fclose(fid);
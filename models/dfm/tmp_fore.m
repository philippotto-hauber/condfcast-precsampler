clear; close all; clc; 

addpath('../../functions')
dir_in = 'C:\Users\Philipp\Documents\Dissertation\condfcast-precsampler\models\dfm\';

% vintage
v = '2006-04-05'; 

% load estim output
load([dir_in, 'out_dfm_', v, '.mat']);

%% unconditional forecasts
y_o = out_dfm.y_o;
y_f = NaN(size(out_dfm.y_c));
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
store_Y_fore = NaN(size(y_f, 1), size(y_o, 2), size(out_dfm.draws.lam, 3));
for m = 1:size(out_dfm.draws.lam, 3)
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore(:, :, m) = Yplus(end-size(y_f, 1)+1:end, :);    
end

med_fore = median(store_Y_fore, 3);
upp_fore = prctile(store_Y_fore, [90], 3);
low_fore = prctile(store_Y_fore, [10], 3);




%% conditional forecasts
y_o = out_dfm.y_o;
y_f = out_dfm.y_c;
p_z = p_timet([y_o; y_f]', out_dfm.options.Nr);
store_Y_fore_c = NaN(size(y_f, 1), size(y_o, 2), size(out_dfm.draws.lam, 3));
for m = 1:size(out_dfm.draws.lam, 3)
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, out_dfm.draws.phi(:, :, m),  eye(out_dfm.options.Nr), out_dfm.draws.lam(:, :, m), out_dfm.draws.psi(:, :, m), out_dfm.draws.sig2(:, m), p_z, 1);
    store_Y_fore_c(:, :, m) = Yplus(end-size(y_f, 1)+1:end, :);    
end

med_fore_c = median(store_Y_fore_c, 3);
upp_fore_c = prctile(store_Y_fore_c, [90], 3);
low_fore_c = prctile(store_Y_fore_c, [10], 3);

figure;
ind_n = 46;
plot([y_o(:, ind_n); med_fore(:, ind_n)], 'b-')
hold on
plot([y_o(:, ind_n); upp_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); low_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); med_fore_c(:, ind_n)], 'r-')
plot([y_o(:, ind_n); upp_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); low_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); NaN(size(y_f, 1), 1)], 'k-')
title(out_dfm.mnemonics{ind_n})

%% soft conditioning

y_o = out_dfm.y_o;
y_f = NaN(size(out_dfm.y_c));
Nr = 1;
p_z = p_timet([y_o; y_f]', Nr);
y_l = out_dfm.y_l;
y_u = out_dfm.y_u;
ind_cond = not(isnan(y_l));
store_Y_fore_c_soft = NaN(size(y_f, 1), size(y_o, 2), size(out_dfm.draws.lam, 3));
Nsample = 1000;
counter = 1;
while counter < 1000
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
end

med_fore_c_soft = median(store_Y_fore_c_soft, 3);
upp_fore_c_soft = prctile(store_Y_fore_c_soft, [90], 3);
low_fore_c_soft = prctile(store_Y_fore_c_soft, [10], 3);

figure;
ind_n = 2;
plot([y_o(:, ind_n); med_fore(:, ind_n)], 'b-')
hold on
plot([y_o(:, ind_n); upp_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); low_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); med_fore_c(:, ind_n)], 'r-')
plot([y_o(:, ind_n); upp_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); low_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); med_fore_c_soft(:, ind_n)], 'g-')
plot([y_o(:, ind_n); upp_fore_c_soft(:, ind_n)], 'g:')
plot([y_o(:, ind_n); low_fore_c_soft(:, ind_n)], 'g:')
plot([y_o(:, ind_n); NaN(size(y_f, 1), 1)], 'k-')
title(out_dfm.mnemonics{ind_n})

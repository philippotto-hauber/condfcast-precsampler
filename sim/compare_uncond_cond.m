clear; close all; 
% compare conditional and unconditional densities

addpath('./DK2002')
addpath('./CK1994')
addpath('../functions')
rng(1234) % set random seed for reproducibility

% set dims, model and load dgp
dir_in = 'C:/Users/Philipp/Documents/Dissertation/condfcast-precsampler/sim/dgp/';
n = 6;
g = 1;
[dims, model, dims_str] = get_dims(n);
dims.ind_n_hard = 1;
dims.ind_n_soft = 2; 
load([dir_in, model, '_', dims_str, '_g_' num2str(g) '.mat']);

Nm = 1000; 
max_iter = 1e3;

[T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);


% unconditional forecasts
if strcmp(model, 'var')
Y_o = [];
else
    Y_o = simdata.y;
end
Y_f = NaN(dims.Nn, dims.Nh);
Y_u = [];
Y_l = [];

y_uncond = NaN(dims.Nn, dims.Nh, Nm); 
for m = 1:Nm
[~, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
y_uncond(:,:,m) = Ydraw; 
end

% conditional forecasts
Y_f(dims.ind_n_hard, dims.ind_h) = simdata.yfore(dims.ind_n_hard, dims.ind_h);

y_cond = NaN(dims.Nn, dims.Nh, Nm);
for m = 1:Nm
[~, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
y_cond(:,:,m) = Ydraw; 
end


% plot unconditional and conditional predictive densities for the soft
% conditioning variables
figure;
counter = 0;
i_offset = dims.ind_n_hard(end); 
for t = 1:dims.Nh
    for i = dims.ind_n_soft
    counter=counter+1;
    upper = simdata.yfore(i, t) + 2*std(simdata.y(i, :));
    lower = simdata.yfore(i, t) - 2*std(simdata.y(i, :));
    subplot(dims.Nh,2,counter)
    histogram(y_uncond(i, t, :))
    hold on
    histogram(y_cond(i, t, :))
    xline(simdata.yfore(i, t), 'LineWidth', 2)
    xline(upper, 'LineWidth', 2, 'LineStyle', ':')
    xline(lower, 'LineWidth', 2, 'LineStyle', ':')
    title(['t=' num2str(dims.Nt+t), ',n=' num2str(i)])    
    end
end

% calculate share of accepted draws 
counter = 0;
for m = 1:Nm         
    acc = true;
    for i = dims.ind_n_soft        
        upper = simdata.yfore(i, :) + std(simdata.y(i, :));
        lower = simdata.yfore(i, :) - std(simdata.y(i, :));
        if not(all(y_cond(i, :, m) > lower) & all(y_cond(i, :, m) < upper))
            acc = false;
            break;
        end
    end
    if acc 
        counter = counter + 1;
    end
end
share_acc = counter / Nm;        


figure; 
plot([simdata.y(i, end-9:end), simdata.yfore(i, :)]', 'k--')
hold on
plot([NaN(1, 10), squeeze(quantile(y_uncond(i, :, :), 0.1, 3))]', 'b:');
plot([NaN(1, 10), squeeze(quantile(y_uncond(i, :, :), 0.9, 3))]', 'b:');
plot([NaN(1, 10), squeeze(quantile(y_uncond(i, :, :), 0.5, 3))]', 'b-');
plot([NaN(1, 10), squeeze(quantile(y_cond(i, :, :), 0.1, 3))]', 'r:');
plot([NaN(1, 10), squeeze(quantile(y_cond(i, :, :), 0.9, 3))]', 'r:');
plot([NaN(1, 10), squeeze(quantile(y_cond(i, :, :), 0.5, 3))]', 'r-');
plot([simdata.y(i, end-9:end), NaN(1, dims.Nh)]', 'k-')

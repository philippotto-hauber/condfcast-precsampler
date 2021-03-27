clear; close all; clc;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
addpath('../sim/')

rng(1234)

%% simulate data
% set-up
Nt = 50;
Nh = 20; 
Nn = 10;
Nr = 1;

simdata = sim_data(Nt, Nh, Nn, Nr);

%% sample unconditional and conditional forecasts

Nm = 500; % # of draws

% unconditional forecasts
Y = [simdata.y NaN(Nn, Nh)];

p_z = p_timet(Y, Nr);

store_aalpha_u = NaN(Nr, Nt+Nh, Nm);
store_Yfore_u = NaN(Nn, Nh, Nm);
for m = 1:Nm
    [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
    store_aalpha_u(:, :, m) = fdraw;
    store_Yfore_u(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
end

% conditional forecasts (hard)
Y_c = NaN(Nn, Nh);
Y_c(1,:) = simdata.yfore(1,:);
Y_c(2,1:Nh/2) = simdata.yfore(2,1:Nh/2);
Y = [simdata.y Y_c];
p_z = p_timet(Y, Nr);

store_aalpha_c_h = NaN(Nr, Nt+Nh, Nm);
store_Yfore_c_h = NaN(Nn, Nh, Nm);
for m = 1:Nm
    [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
    store_aalpha_c_h(:, :, m) = fdraw;
    store_Yfore_c_h(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
end

% conditional forecasts (soft)
Y = [simdata.y];
sig = sqrt(var(simdata.y, [], 2));
Y_u = NaN(Nn, Nh);
%Y_u(1,1:Nh) = simdata.yfore(1,1:Nh) + repmat(1 * sig(1, 1), 1, Nh);
%Y_u(2,1:Nh/2) = simdata.yfore(2,1:Nh/2) + repmat(1 * sig(2, 1), 1, Nh/2);
Y_u(1:Nn/10,:) = simdata.yfore(1:Nn/10,1:Nh) + repmat(3 * sig(1:Nn/10, 1), 1, Nh);
Y_l = NaN(Nn, Nh);
%Y_l(1:Nn/10,1:Nh/2) = simdata.yfore(1:Nn/10,1:Nh/2) - repmat(1 * sig(1:Nn/10, 1), 1, Nh/2);
Y_l(1:Nn/10,:) = 0; 

p_z = p_timet([Y, NaN(Nn, Nh)], Nr);

store_aalpha_c_s = NaN(Nr, Nt+Nh, Nm);
store_Yfore_c_s = NaN(Nn, Nh, Nm);
max_iter = 5000;
m = 1; 
while m < Nm
    [fdraw, Ydraw, iter] = sample_z_softcond(Y, Nh, Y_l, Y_u, simdata.params, p_z, max_iter);
    if iter < max_iter
        m = m + 1;
        store_aalpha_c_s(:, :, m) = fdraw;
        store_Yfore_c_s(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
    end
end

%% plot states and series

% quantiles of draws
q_u.aalpha = calc_quantiles(store_aalpha_u); 
q_u.Yfore = calc_quantiles(store_Yfore_u); 
q_c_h.aalpha = calc_quantiles(store_aalpha_c_h); 
q_c_h.Yfore = calc_quantiles(store_Yfore_c_h); 
q_c_s.aalpha = calc_quantiles(store_aalpha_c_s); 
q_c_s.Yfore = calc_quantiles(store_Yfore_c_s); 

quantiles_draw_aalpha_u = quantile(store_aalpha_u, [0.1 0.5 0.9], 3); 
med_aalpha_u = quantiles_draw_aalpha_u(:, :, 2);
upper_aalpha_u = quantiles_draw_aalpha_u(:, :, 3);
lower_aalpha_u = quantiles_draw_aalpha_u(:, :, 1);

quantiles_draw_aalpha_c = quantile(store_aalpha_c_h, [0.1 0.5 0.9], 3); 
med_aalpha_c = quantiles_draw_aalpha_c(:, :, 2);
upper_aalpha_c = quantiles_draw_aalpha_c(:, :, 3);
lower_aalpha_c = quantiles_draw_aalpha_c(:, :, 1);

quantiles_draw_Yfore_u = quantile(store_Yfore_u, [0.1 0.5 0.9], 3); 
med_Yfore_u = quantiles_draw_Yfore_u(:, :, 2);
upper_Yfore_u = quantiles_draw_Yfore_u(:, :, 3);
lower_Yfore_u = quantiles_draw_Yfore_u(:, :, 1);

quantiles_draw_Yfore_c = quantile(store_Yfore_c_h, [0.1 0.5 0.9], 3); 
med_Yfore_c = quantiles_draw_Yfore_c(:, :, 2);
upper_Yfore_c = quantiles_draw_Yfore_c(:, :, 3);
lower_Yfore_c = quantiles_draw_Yfore_c(:, :, 1);

% figure
figure(1)
fig = gcf;
fig.PaperOrientation = 'portrait';
subplot(4,1,1)
ind_n = 1;
flag_alpha = true;
plot_draws_actuals(simdata, q_u.aalpha, q_c_h.aalpha, q_c_s.aalpha, ind_n, Nh, '$$\alpha_{1:T+H}$$', flag_alpha)
subplot(4,1,2)
ind_n = 1;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{1,1:T+H}$$', flag_alpha)
subplot(4,1,3)
ind_n = 2;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{2,1:T+H}$$', flag_alpha)
subplot(4,1,4)
ind_n = 10;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{10,1:T+H}$$', flag_alpha)
print('../figures/fig_fore.pdf','-dpdf','-fillpage') ; 

figure; 
ind_n = 10;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{10,1:T+H}$$', flag_alpha)

figure; 
ind_n = 2;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{2,1:T+H}$$', flag_alpha)

figure; 
ind_n = 1;
flag_alpha = false;
plot_draws_actuals(simdata, q_u.Yfore, q_c_h.Yfore, q_c_s.Yfore, ind_n, Nh, '$$y_{1,1:T+H}$$', flag_alpha)


%% functions

function q = calc_quantiles(x)
tmp = quantile(x, [0.1 0.5 0.9], 3); 
q.upper = tmp(:, :, 3);
q.med = tmp(:, :, 2);
q.lower = tmp(:, :, 1);
end

% 
% colors = [[1 .5 0]; [0.6 0 0.6]; [0 0 1]; [0 0 1]];

function plot_draws_actuals(simdata, q_u, q_c_h, q_c_s, ind_n, Nh, title_str, flag_alpha)
if flag_alpha
    p1 = plot(simdata.aalpha(ind_n,:)', 'k-');
    hold on
    p2 = plot(q_u.med(ind_n, :)', 'Color', [1 .5 0], 'LineStyle', '-');
    plot([q_u.upper(ind_n, :); q_u.lower(ind_n, :)]', 'Color', [1 .5 0], 'LineStyle', ':')
    p3 = plot(q_c_h.med(ind_n, :)', 'Color', [0.6 0 0.6], 'LineStyle', '-');
    plot([q_c_h.lower(ind_n, :); q_c_h.upper(ind_n, :)]', 'Color', [0.6 0 0.6], 'LineStyle', ':')    
    p4 = plot(q_c_s.med(ind_n, :)', 'Color', [0 0 1], 'LineStyle', '-');
    plot([q_c_s.lower(ind_n, :); q_c_s.upper(ind_n, :)]', 'Color', [0 0 1], 'LineStyle', ':')
    plot([simdata.aalpha(ind_n, 1:size(simdata.aalpha, 2)-Nh), NaN(1, Nh)]', 'k-', 'LineWidth', 1.1);
else    
    p1 = plot([simdata.y(ind_n, :), simdata.yfore(ind_n,:)]', 'k-');
    hold on
    p2 = plot([simdata.y(ind_n, :) q_u.med(ind_n, :)]', 'Color', [1 .5 0], 'LineStyle', '-');
    plot([[simdata.y(ind_n, :), q_u.upper(ind_n, :)]; [simdata.y(ind_n, :), q_u.lower(ind_n, :)]]', 'Color', [1 .5 0], 'LineStyle', ':')
    p3 = plot([simdata.y(ind_n, :) , q_c_h.med(ind_n, :)]', 'Color', [0.6 0 0.6], 'LineStyle', '-');
    plot([[simdata.y(ind_n, :), q_c_h.lower(ind_n, :)]; [simdata.y(ind_n, :), q_c_h.upper(ind_n, :)]]', 'Color', [0.6 0 0.6], 'LineStyle', ':')    
    p4 = plot([simdata.y(ind_n, :), q_c_s.med(ind_n, :)]', 'Color', [0 0 1], 'LineStyle', '-');
    plot([[simdata.y(ind_n, :), q_c_s.lower(ind_n, :)]; [simdata.y(ind_n, :), q_c_s.upper(ind_n, :)]]', 'Color', [0 0 1], 'LineStyle', ':')
    plot([simdata.y(ind_n, :) NaN(1, Nh)]', 'k-', 'LineWidth', 1.1);
end
    legend([p1, p2, p3, p4], {'actual', 'unconditional', 'conditional (hard)', 'conditional (soft)'}, 'Location', 'SouthWest')
    title(title_str, 'interpreter','latex', 'Fontsize', 11)
end

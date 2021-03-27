clear; close all; clc;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
addpath('../sim/')

rng(1234)

%% set-up 
Nt = 50;
Nh = 20; 
Nn = 10;
Nr = 1;
Nm = 500; 

% simulate data
simdata = generate_data(Nt, Nh, Nn, Nr);

%% sample unconditional and conditional forecasts

Nm = 500; % # of draws

% unconditional forecasts
Y_o = simdata.y;
Y_f = NaN(Nn, Nh);
Y_l = [];
Y_u = [];

p_z = p_timet([Y_o, Y_f], Nr);

store_aalpha_u = NaN(Nr, Nt+Nh, Nm);
store_Yfore_u = NaN(Nn, Nh, Nm);
for m = 1:Nm
    [store_aalpha_u(:, :, m), store_Yfore_u(:, :, m)] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z);
end

% conditional forecasts (hard)
Y_f = NaN(Nn, Nh);
Y_f(1,:) = simdata.yfore(1,:);
Y_f(2,1:Nh/2) = simdata.yfore(2,1:Nh/2);
Y_l = [];
Y_u = [];
p_z = p_timet([Y_o, Y_f], Nr);

store_aalpha_c_h = NaN(Nr, Nt+Nh, Nm);
store_Yfore_c_h = NaN(Nn, Nh, Nm);
for m = 1:Nm
      [store_aalpha_c_h(:, :, m), store_Yfore_c_h(:, :, m)] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z);
end

% conditional forecasts (soft)
Y_o = simdata.y;
Y_f = NaN(Nn, Nh); 
sig = sqrt(var(simdata.y, [], 2));

% two sets of restrictions
restr = 'y1 < 0' ; %{'y1,y2 +- 1 std. dev.', 'y1 < 0'}
Y_u = NaN(Nn, Nh);
Y_l = NaN(Nn, Nh);
if strcmp(restr, 'y1,y2 +- 1 std. dev.')    
    Y_u(1,1:Nh) = simdata.yfore(1,1:Nh) + repmat(1 * sig(1, 1), 1, Nh);
    Y_u(2,1:Nh/2) = simdata.yfore(2,1:Nh/2) + repmat(1 * sig(2, 1), 1, Nh/2);
    Y_l(1:Nn/10,1:Nh/2) = simdata.yfore(1:Nn/10,1:Nh/2) - repmat(1 * sig(1:Nn/10, 1), 1, Nh/2);
    Y_l(2,1:Nh/2) = simdata.yfore(2,1:Nh/2) - repmat(1 * sig(2, 1), 1, Nh/2);
elseif strcmp(restr, 'y1 < 0')
    Y_u(1:Nn/10,:) = 0;
    Y_l(1:Nn/10,1:Nh) = simdata.yfore(1:Nn/10,1:Nh) - repmat(3 * sig(1:Nn/10, 1), 1, Nh);
end
p_z = p_timet([Y_o, Y_f], Nr);

store_aalpha_c_s = NaN(Nr, Nt+Nh, Nm);
store_Yfore_c_s = NaN(Nn, Nh, Nm);
for m = 1:Nm
     [store_aalpha_c_s(:, :, m), store_Yfore_c_s(:, :, m)] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z);
end

%% plot states and series

% quantiles of draws
q_u.aalpha = calc_quantiles(store_aalpha_u); 
q_u.Yfore = calc_quantiles(store_Yfore_u); 
q_c_h.aalpha = calc_quantiles(store_aalpha_c_h); 
q_c_h.Yfore = calc_quantiles(store_Yfore_c_h); 
q_c_s.aalpha = calc_quantiles(store_aalpha_c_s); 
q_c_s.Yfore = calc_quantiles(store_Yfore_c_s); 



% figure
figure
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

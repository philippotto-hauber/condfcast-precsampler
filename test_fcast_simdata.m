clear; close all; clc;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%- This code implements standard precision-sampling in a state space model
%- as well as unconditional and conditional forecasting. Codes are
%- illustrated with simulated data from a dynamic factor model. Main output
%- are three plots: i) the sampled factors in the three scenarios compared 
%- with actuals, ii) the unconditional and conditional predictive 
%- distributions for a number of series, iii) bar plots of the range of the
%- predictive densities 90 percent interval at time Nt+Nh for both un-
%- conditional and conditional forecasts. 
%- Auxiliary functions are: 
%-      f_sample_z - samples the (permuted) vector of states and
%-                   "missings", i.e. forecasts
%-      construct_PQP - constructs the precision matrix Q_z and permutes it
%-                      according to p_z
%-      p_timet - builds the permuation vector p_z to reorder the model by
%-                time periods
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% simulate data
%-------------------------------------------------------------------------%
simdata_dfm;
close all;

%-------------------------------------------------------------------------%
% load data
%-------------------------------------------------------------------------%
load('simdata.mat')

%-------------------------------------------------------------------------%
% back-out dimensions
%-------------------------------------------------------------------------%
[Nn, Nt] = size(simdata.Yobs);
Nr = size(simdata.f, 1);

%-------------------------------------------------------------------------%
% manual input
%-------------------------------------------------------------------------%
Nm = 1000; % # of draws
ind_ns = [1, Nn/2+1, Nn-1, Nn]; % series to plot
ind_cond = 1:Nn/2; % conditioning set of variables

%-------------------------------------------------------------------------%
% sample f based on complete data Yobs
%-------------------------------------------------------------------------%
Y = simdata.Yobs;
p_z = p_timet(Y, Nr);

store_f = NaN(Nr, Nt, Nm);
tic;
for m = 1:Nm
    [fdraw, ~] = sample_z(simdata.Yobs, simdata.params, p_z);
    store_f(:, :, m) = fdraw;
end
toc;

% plot factors
figure(1);
subplot(3,1,1)
plot_factors(store_f, simdata, 'complete data')


%-------------------------------------------------------------------------%
% unconditional forecasts: sample f and missing y
%-------------------------------------------------------------------------%

Nh = size(simdata.Yfore, 2);
Y = [simdata.Yobs NaN(Nn, Nh)];
p_z = p_timet(Y, Nr);

store_f = NaN(Nr, Nt+Nh, Nm);
store_Yfore = NaN(Nn, Nh, Nm);
tic;
for m = 1:Nm
    [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
    store_f(:, :, m) = fdraw;
    store_Yfore(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
end
toc;

% plot factors
figure(1);
subplot(3,1,2)
plot_factors(store_f, simdata, 'unconditional forecast: factors')

% plot series
figure(2)
plot_Yfore(store_Yfore, simdata, ind_ns, 'series', [0 0 1])

figure(3);
subplot(1,2,1)
tmp = store_Yfore(:, end, :);
tmp2 = squeeze(quantile(tmp, [0.1, 0.9], 3));
range_Yfore_NtNh = tmp2(:, 2) - tmp2(:, 1);
bar(range_Yfore_NtNh);title('range of pred dens: unconditional forecasts')

%-------------------------------------------------------------------------%
% conditional forecasts: sample f and missing y
%-------------------------------------------------------------------------%

Nh = size(simdata.Yfore, 2);
ycond = NaN(Nn, Nh);
ycond(ind_cond, :) = simdata.Yfore(ind_cond,:);
Y = [simdata.Yobs ycond];
p_z = p_timet(Y, Nr);

Nm = 1000;
store_f = NaN(Nr, Nt+Nh, Nm);
store_Yfore = NaN(Nn, Nh, Nm);
tic;
for m = 1:Nm
    [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
    store_f(:, :, m) = fdraw;
    store_Yfore(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
end
toc;

% plot factors
figure(1);
subplot(3,1,3)
plot_factors(store_f, simdata, 'conditional forecast: factors')

% plot series
figure(2)
plot_Yfore(store_Yfore, simdata, ind_ns, 'series', [1 0 0])

tmp = store_Yfore(:, end, :);
tmp2 = squeeze(quantile(tmp, [0.1, 0.9], 3));
range_Yfore_NtNh = tmp2(:, 2) - tmp2(:, 1);
figure(3);
subplot(1,2,2)
bar(range_Yfore_NtNh);title('range of pred dens: conditional forecasts')

%-------------------------------------------------------------------------%
% conditional forecasts: sample f and missing y
%-------------------------------------------------------------------------%


function plot_factors(store_f, simdata, title_str)

% quantiles of draws
quantiles_draw_f = quantile(store_f, [0.1 0.5 0.9], 3); 
med_f = quantiles_draw_f(:, :, 2);
upper_f = quantiles_draw_f(:, :, 3);
lower_f = quantiles_draw_f(:, :, 1);

% plot
plot(simdata.f(1,:), 'k-')
hold on
plot(med_f(1,:), 'b-')
plot(lower_f(1,:), 'b:')
plot(upper_f(1,:), 'b:')
plot(simdata.f(2,:), 'k-')
plot(med_f(2,:), 'r-')
plot(lower_f(2,:), 'r:')
plot(upper_f(2,:), 'r:')
title(title_str)
end

function plot_Yfore(store_Yfore, simdata, ind_ns, title_str, col)
    quantiles_draw_Yfore= quantile(store_Yfore, [0.1 0.5 0.9], 3); 
    med_Yfore = quantiles_draw_Yfore(:, :, 2);
    upper_Yfore = quantiles_draw_Yfore(:, :, 3);
    lower_Yfore = quantiles_draw_Yfore(:, :, 1);

    for i = 1:length(ind_ns)
    subplot(length(ind_ns), 1, i)
    ind_n = ind_ns(i);
    plot([simdata.Yobs(ind_n,:) med_Yfore(ind_n,:)], '-', 'Color', col)
    hold on
    plot([simdata.Yobs(ind_n,:) lower_Yfore(ind_n,:)], ':', 'Color', col)
    plot([simdata.Yobs(ind_n,:) upper_Yfore(ind_n,:)], ':', 'Color', col)
    plot([simdata.Yobs(ind_n,:) simdata.Yfore(ind_n, :)], 'k-')
    title([title_str, num2str(ind_n)])
    ylim([-4, 4])
    end
end


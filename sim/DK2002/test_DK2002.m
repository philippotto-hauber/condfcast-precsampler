clear; close all; 
%% Description --------------------------------------------------------- %%
%  This code tests the function simsmoothCK.m in different forecasting 
%  settings (ftype):
%           -standard simulation smoothing, i.e. no forecasting
%           -unconditional forecasting
%           -conditional forecasting with hard, i.e. exact conditions
%           -conditional forecasting with soft, i.e. interval conditions
%  Artifical data from a state space model are generated and Nm draws from 
%  the posterior distribution are sampled. The results for the factors and
%  both restricted and unrestricted series are plotted.
%------------------------------------------------------------------------ %

%% set-up

addpath('../../sim/') % path to generate_data.m

rng(1234) % set random seed for reproducibility

Nt = 50; % # of in-sample observations
Nn = 10; % # of variables
Ns = 1; % # of states
Nm = 1000; % # of draws

% type of forecast
ftype = 'conditional (hard)'; % {'none', 'unconditional', 'conditional (hard)', 'conditional (soft)'} 

% forecast horizon
if strcmp(ftype, 'none')
    Nh = 0; 
else
    Nh = 20;
end


%% simulate data, state space params
simdata = generate_data(Nt, Nh, Nn, Ns);

% observables
Y_o = simdata.y; 

% state space params
T = simdata.params.phi; 
Z = simdata.params.lambda;
H = diag(simdata.params.sig_eps);
Q = simdata.params.sig_ups; 
R = eye(Ns); 
s0 = zeros(size(T, 1), 1); 
P0 = 1 * eye(size(T, 1));

%% no forecasting => standard simulation smoothing

% construct input args Y_f, Y_l, Y_u
if strcmp(ftype, 'none')
    Y_f = NaN(Nn, Nh);
    Y_u = [];
    Y_l = [];
    adraw = NaN(Ns, Nt, Nm);
    tic
    for m = 1:Nm
        [adraw(:, :, m), ~] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0);
    end
    toc
end

%% unconditional forecasting
% construct input args Y_f, Y_l, Y_u
if strcmp(ftype, 'unconditional')
    Y_f = NaN(Nn, Nh);
    Y_u = [];
    Y_l = [];
    
    % CK sim smoother
    adraw = NaN(Ns, Nt+Nh, Nm);
    Ydraw = NaN(Nn, Nh, Nm);

    tic
    for m = 1:Nm
        [adraw(:, :, m), Ydraw(:, :, m)] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0);
    end
    toc
end

%% conditional forecasting (hard)

if strcmp(ftype, 'conditional (hard)')
    Y_f = NaN(Nn, Nh);
    Y_f(1, :) = simdata.yfore(1, :);
    Y_f(2, 1:Nh/2) = simdata.yfore(2, 1:Nh/2);
    Y_u = [];
    Y_l = [];
    
    % CK sim smoother
    adraw = NaN(Ns, Nt+Nh, Nm);
    Ydraw = NaN(Nn, Nh, Nm);

    tic
    for m = 1:Nm
        [adraw(:, :, m), Ydraw(:, :, m)] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0);
    end
    toc
end


%% plot 
figure;
plot(simdata.aalpha', 'k-')
hold on
plot(quantile(adraw, 0.5, 3)', 'b-')
plot(quantile(adraw, 0.1, 3)', 'b:')
plot(quantile(adraw, 0.9, 3)', 'b:')
title(['states, ' ftype])

if ~strcmp(ftype, 'none')
    figure;
    subplot(3,1,1)
    ind_n = 1; 
    plot([simdata.y(ind_n, :) simdata.yfore(ind_n, :)]', 'k-')
    hold on
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.5, 3)], 'b-')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.1, 3)], 'b:')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.9, 3)], 'b:')
    title([ftype, ', y_{' num2str(ind_n) '}'])
    subplot(3,1,2)
    ind_n = 2; 
    plot([simdata.y(ind_n, :) simdata.yfore(ind_n, :)]', 'k-')
    hold on
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.5, 3)], 'b-')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.1, 3)], 'b:')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.9, 3)], 'b:')
    title([ftype, ', y_{' num2str(ind_n) '}'])
    subplot(3,1,3)
    ind_n = Nn; 
    plot([simdata.y(ind_n, :) simdata.yfore(ind_n, :)]', 'k-')
    hold on
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.5, 3)], 'b-')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.1, 3)], 'b:')
    plot([simdata.y(ind_n, :), quantile(Ydraw(ind_n, :, :), 0.9, 3)], 'b:')
    title([ftype, ', y_{' num2str(ind_n) '}'])
end
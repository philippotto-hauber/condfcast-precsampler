clear; close all; clc;

addpath('../../../functions')
addpath('../../dfm/')

% simulate data
Nt = 7;
Nh = 2; 
Nn = 3;
Nr = 2; 
Nj = 1; 
Np = 2;
Ns = 1;

simdata = simdata_dfm(Nt, Nh, Nn, Nr, Nj, Np, Ns);


% data
y_o = simdata.Yobs';

% MCMC options
options.Nburnin = 1000 ; % # of burn-ins
options.Nreplic = 1000 ; % # of replics
options.Nthin = 2 ; % store each options.thinning-th draw
options.Ndisplay = 1000 ;  % display each options.display-th iteration

% model specs
options.Nr = Nr;
options.Nj = Nj;
options.Ns = Ns;
options.Np = Np;

% estimate model
draws = GibbsSampler_dfm(y_o, options);

% unconditional forecast
y_f = NaN(size(simdata.Yfore'));
Ndraws = size(draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', options.Nr);
store_Y_fore = NaN(Nh, Nn, Ndraws);
for m = 1:Ndraws
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, draws.phi(:, :, m),  eye(options.Nr), draws.lam(:, :, m), draws.psi(:, :, m), draws.sig2(:, m), p_z, 1);
    store_Y_fore(:, :, m) = Yplus(end-size(y_f, 1)+1:end, :);  
end

med_fore = median(store_Y_fore, 3);
upp_fore = prctile(store_Y_fore, [90], 3);
low_fore = prctile(store_Y_fore, [10], 3);

% conditional forecast
y_f = NaN(size(simdata.Yfore'));
y_f(:, 1:10) = simdata.Yfore(1:10, :)';
Ndraws = size(draws.lam, 3);
Nh = size(y_f, 1);
Nn = size(y_f, 2); 
p_z = p_timet([y_o; y_f]', options.Nr);
store_Y_fore_c = NaN(Nh, Nn, Ndraws);

for m = 1:Ndraws
    [f, Yplus] = f_simsmoothsHS(y_o, y_f, draws.phi(:, :, m),  eye(options.Nr), draws.lam(:, :, m), draws.psi(:, :, m), draws.sig2(:, m), p_z, 1);
    store_Y_fore_c(:, :, m) = Yplus(end-size(y_f, 1)+1:end, :);  
end

med_fore_c = median(store_Y_fore_c, 3);
upp_fore_c = prctile(store_Y_fore_c, [90], 3);
low_fore_c = prctile(store_Y_fore_c, [10], 3);

figure;
ind_n = 1;
plot([y_o(:, ind_n); med_fore(:, ind_n)], 'b-')
hold on
plot([y_o(:, ind_n); upp_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); low_fore(:, ind_n)], 'b:')
plot([y_o(:, ind_n); med_fore_c(:, ind_n)], 'r-')
plot([y_o(:, ind_n); upp_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); low_fore_c(:, ind_n)], 'r:')
plot([y_o(:, ind_n); simdata.Yfore(ind_n,:)'], 'k:')
plot([y_o(:, ind_n); NaN(size(y_f, 1), 1)], 'k-')

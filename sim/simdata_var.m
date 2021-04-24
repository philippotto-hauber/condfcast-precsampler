clear; close all; 
% test VAR code

addpath('./CK1994')
addpath('./DK2002')
addpath('../precsampler')
addpath('../functions')
rng(1234) % set random seed for reproducibility

% set dims, model and load dgp
dir_in = 'C:/Users/Philipp/Documents/Dissertation/condfcast-precsampler/sim/dgp/';
n = 4;
g = 1;
[dims, model, dims_str] = get_dims(n);
load([dir_in, model, '_', dims_str, '_g_' num2str(g) '.mat']);

% test soft and hard conditions
max_iter = 1e3;
ind_n_soft = 2; 
sig = sqrt(var(simdata.y, [], 2));
Y_o = [];
Y_f = NaN(dims.Nn, dims.Nh);
Y_f(1, :) = simdata.yfore(1,:);
Y_u = []; 
%Y_u = NaN(dims.Nn, dims.Nh);                    
%Y_u(ind_n_soft, dims.ind_h) = simdata.yfore(ind_n_soft, dims.ind_h) + repmat(1 * sig(ind_n_soft, 1), 1, length(dims.ind_h));
Y_l = []; 
%Y_l = NaN(dims.Nn, dims.Nh);
%Y_l(ind_n_soft, dims.ind_h) = simdata.yfore(ind_n_soft, dims.ind_h) - repmat(1 * sig(ind_n_soft, 1), 1, length(dims.ind_h));

% CK & DK
[T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);

%[sdrawCK, YdrawCK] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0, max_iter);

Nm = 100; 
for m = 1:Nm
[sdrawDK, YdrawDK] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
store_a(:,:,m) = sdrawDK;
store_y(:,:,m) = YdrawDK; 
end

% HS
Y_o = simdata.y(:, end-dims.Np+1:end); 
Nt = size(Y_o, 2); 
% vectorized yobs, removing missings
y = vec([Y_o, Y_f]); 
yobs = y(~isnan(y),1); 
Nmis = sum(isnan(y));
Nobs = sum(~isnan(y));

p_z = p_timet([Y_o, Y_f], 0);

% % precision matrix Q
% [PQP_fymis, PQP_fymis_yobs] = construct_PQP(simdata.params, dims.Nt*dims.Nh, Nmis, p_z, model);
% 
% chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
% b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);
% fxmis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis); % draw joint 
% 
% z_draw(p_z, :) = [fxmis_draw; repmat(yobs, 1)]; % reverse permutation => z = [ vec([Y_o, Y_f])]!
% Ydraw = reshape(z_draw(Nt*dims.Nn+1:end, :), dims.Nn, dims.Nh);

[~, YdrawHS] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z, max_iter, model);

ind_n = 1; 
figure; 
plot([simdata.y(ind_n, :), simdata.yfore(ind_n, :)], 'k--')
hold on
plot([simdata.y(ind_n, :), YdrawCK(ind_n, :)], 'b-')
plot([simdata.y(ind_n, :), YdrawDK(ind_n, :)], 'r-')
plot([simdata.y(ind_n, :), YdrawHS(ind_n, :)], 'g-')
plot([simdata.y(ind_n, :), NaN(1, dims.Nh)], 'k-')
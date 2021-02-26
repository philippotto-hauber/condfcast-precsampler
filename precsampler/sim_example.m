clear; close all; clc;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
rng(1234)
%% simulate data
% set-up
Nt = 50;
Nh = 20; 
Nn = 10;
Nr = 1; 

% params
T = 0.7;
Ssigma = 1;
Var_alpha = Ssigma / (1-T^2);
F = sqrt(0.1)*randn(Nn, Nr) + 0.5;
oomega = 0.5 * diag(F * Var_alpha * F');

% loop over t
y = NaN(Nn, Nt+Nh);
aalpha = NaN(Nr, Nt+Nh);
for t = 1:Nt+Nh
    if t == 1
        aalpha(:, t) = sqrt(Ssigma) * randn(1);         
    else
        aalpha(:, t) = T * aalpha(:, t-1) + sqrt(Ssigma) * randn(1);   
    end
    y(:, t) = F * aalpha(:, t) + oomega .* randn(Nn, 1);
end

% store in structure
simdata.y = y(:, 1:Nt);
simdata.yfore = y(:, Nt+1:end);
simdata.aalpha = aalpha;
simdata.params.phi = T;
simdata.params.psi = [];
simdata.params.lambda = F;
simdata.params.sig_eps = oomega;
simdata.params.sig_ups = Ssigma; 

%% sample unconditional and conditional forecasts

Nm = 1000; % # of draws

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

% conditional forecasts
Y_c = NaN(Nn, Nh);
Y_c(1,:) = simdata.yfore(1,:);
Y_c(2,1:Nh/2) = simdata.yfore(2,1:Nh/2);
Y = [simdata.y Y_c];
p_z = p_timet(Y, Nr);

store_aalpha_c = NaN(Nr, Nt+Nh, Nm);
store_Yfore_c = NaN(Nn, Nh, Nm);
for m = 1:Nm
    [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
    store_aalpha_c(:, :, m) = fdraw;
    store_Yfore_c(:, :, m) = Ydraw(:, Nt+1:Nt+Nh);
end

%% plot states and series

% quantiles of draws
quantiles_draw_aalpha_u = quantile(store_aalpha_u, [0.1 0.5 0.9], 3); 
med_aalpha_u = quantiles_draw_aalpha_u(:, :, 2);
upper_aalpha_u = quantiles_draw_aalpha_u(:, :, 3);
lower_aalpha_u = quantiles_draw_aalpha_u(:, :, 1);

quantiles_draw_aalpha_c = quantile(store_aalpha_c, [0.1 0.5 0.9], 3); 
med_aalpha_c = quantiles_draw_aalpha_c(:, :, 2);
upper_aalpha_c = quantiles_draw_aalpha_c(:, :, 3);
lower_aalpha_c = quantiles_draw_aalpha_c(:, :, 1);

quantiles_draw_Yfore_u = quantile(store_Yfore_u, [0.1 0.5 0.9], 3); 
med_Yfore_u = quantiles_draw_Yfore_u(:, :, 2);
upper_Yfore_u = quantiles_draw_Yfore_u(:, :, 3);
lower_Yfore_u = quantiles_draw_Yfore_u(:, :, 1);

quantiles_draw_Yfore_c = quantile(store_Yfore_c, [0.1 0.5 0.9], 3); 
med_Yfore_c = quantiles_draw_Yfore_c(:, :, 2);
upper_Yfore_c = quantiles_draw_Yfore_c(:, :, 3);
lower_Yfore_c = quantiles_draw_Yfore_c(:, :, 1);

% figure
figure(1)
fig = gcf;
fig.PaperOrientation = 'portrait';
subplot(4,1,1)
% states
p1 = plot(simdata.aalpha(1,:)', 'k-');
hold on
p2 = plot(med_aalpha_u(1, :)', 'b-');
plot([lower_aalpha_u; upper_aalpha_u]', 'b:')
p3 = plot(med_aalpha_c(1, :)', 'r-');
plot([lower_aalpha_c; upper_aalpha_c]', 'r:')
plot([simdata.aalpha(1,1:Nt) NaN(Nr, Nh)]', 'k-', 'LineWidth', 1.1);
legend([p1, p2, p3], {'actual', 'unconditional', 'conditional'}, 'Location', 'SouthWest')
title('$$\alpha_{1:T+H}$$','interpreter','latex', 'Fontsize', 11)

subplot(4,1,2)
% series 1
ind_n = 1;
p2 = plot([simdata.y(ind_n,:) med_Yfore_u(ind_n, :)]', 'b-');
hold on
plot([simdata.y(ind_n,:) lower_Yfore_u(ind_n, :)]', 'b:');
plot([simdata.y(ind_n,:) upper_Yfore_u(ind_n, :)]', 'b:');
p3 = plot([simdata.y(ind_n,:) med_Yfore_c(ind_n, :)]', 'r-');
plot([simdata.y(ind_n,:) lower_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) upper_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) NaN(1, Nh)]', 'k-', 'LineWidth',1.1);
p1 = plot([simdata.y(ind_n,:) simdata.yfore(ind_n,:)]', 'k-');
legend([p1, p2, p3], {'actual', 'unconditional', 'conditional'}, 'Location', 'SouthWest')
title('$$y_{1,1:T+H}$$','interpreter','latex', 'Fontsize', 11)

subplot(4,1,3)
% series 2
ind_n = 2;
p2 = plot([simdata.y(ind_n,:) med_Yfore_u(ind_n, :)]', 'b-');
hold on
plot([simdata.y(ind_n,:) lower_Yfore_u(ind_n, :)]', 'b:');
plot([simdata.y(ind_n,:) upper_Yfore_u(ind_n, :)]', 'b:');
p3 = plot([simdata.y(ind_n,:) med_Yfore_c(ind_n, :)]', 'r-');
plot([simdata.y(ind_n,:) lower_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) upper_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) NaN(1, Nh)]', 'k-', 'LineWidth',1.1);
p1 = plot([simdata.y(ind_n,:) simdata.yfore(ind_n,:)]', 'k-');
legend([p1, p2, p3], {'actual', 'unconditional', 'conditional'}, 'Location', 'SouthWest')
title('$$y_{2,1:T+H}$$','interpreter','latex', 'Fontsize', 11)

subplot(4,1,4)
% series 10
ind_n = 10;
p2 = plot([simdata.y(ind_n,:) med_Yfore_u(ind_n, :)]', 'b-');
hold on
plot([simdata.y(ind_n,:) lower_Yfore_u(ind_n, :)]', 'b:');
plot([simdata.y(ind_n,:) upper_Yfore_u(ind_n, :)]', 'b:');
p3 = plot([simdata.y(ind_n,:) med_Yfore_c(ind_n, :)]', 'r-');
plot([simdata.y(ind_n,:) lower_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) upper_Yfore_c(ind_n, :)]', 'r:');
plot([simdata.y(ind_n,:) NaN(1, Nh)]', 'k-', 'LineWidth',1.1);
p1 = plot([simdata.y(ind_n,:) simdata.yfore(ind_n,:)]', 'k-');
legend([p1, p2, p3], {'actual', 'unconditional', 'conditional'}, 'Location', 'SouthWest')
title('$$y_{10,1:T+H}$$','interpreter','latex', 'Fontsize', 11)

print('../figures/fig_fore.pdf','-dpdf','-fillpage') ; 

%% plot original and permuted precision matrix
 
Nmis = sum(sum(isnan(Y))); % # of missings

% % get position of missings
% ind_t_vars = kron(ones(Nn, 1), 1:Nt+Nh);
% ind_t_alps = 1:Nt+Nh;
% 
% ind_t = [ind_t_alps'; ind_t_vars(:)];
% 
% ind_nan_orig = ind_t > Nt;
% 
% ind_t_perm = ind_t(p_z);
% 
% ind_nan_perm = ind_t_perm > Nt;
% 
% figure;
% subplot(1,2,1)
% spy(P_z(ind_nan_orig, ind_nan_orig), 'b')
% hold on
% spy(P_z(~ind_nan_orig, ~ind_nan_orig), 'r')
% subplot(1,2,2)
% spy(P_z_perm(ind_nan_perm, ind_nan_perm), 'b')
% hold on
% spy(P_z_perm(~ind_nan_perm, ~ind_nan_perm), 'r')

% permute
[P_z, P_aalphaYfore] = construct_PQP_example(simdata.params, Nt+Nh, Nmis, 1:length(p_z));
[P_z_perm, P_aalphaYfore_perm] = construct_PQP_example(simdata.params, Nt+Nh, Nmis, p_z);

% bandwidth
[bw_z_l, bw_z_u] = bandwidth(P_aalphaYfore);
[bw_z_perm_l, bw_z_perm_u] = bandwidth(P_aalphaYfore_perm);

figure(2);
fig = gcf;
fig.PaperOrientation = 'landscape';
subplot(1,2,1)
spy(P_z)
title('$$P_z$$','interpreter','latex','FontSize',16)
subplot(1,2,2)
spy(P_z_perm)
title('')
title('$$P_{z_{\mathcal{P}''}}$$','interpreter','latex','FontSize',16)

print('../figures/fig_P_perm.pdf','-dpdf','-fillpage') ; 

%% functions

function [PQP, PQP_fymis] = construct_PQP_example(params, Nt, Nmis, p_z)

% back out dims
Nr = size(params.phi, 1);
Np = size(params.phi, 2) / Nr;
Nn = size(params.lambda, 1);
Ns = size(params.lambda, 2) / Nr - 1;
Nj = size(params.psi, 2);

% Llambda
Llambda = kron(speye(Nt), params.lambda(:, 1:Nr));

for s = 1:Ns
    tmp = spdiags(ones(Nt,1), -s, Nt, Nt);
    Llambda = Llambda + kron(tmp, params.lambda(:, Nr*s+1:Nr*(s+1)));
end

% Q_eps and H_e
Q_eps = kron(speye(Nt), eye(Nn) / diag(params.sig_eps)); 
H_e = speye(Nt*Nn);

for j = 1:Nj
    tmp = spdiags(ones(Nt,1), -j, Nt, Nt);
    H_e = H_e + kron(tmp, -diag(params.psi(:, j)));
end

% Q_ups and H_f
Q_ups = kron(speye(Nt), params.sig_ups \ eye(Nr));

H_f = speye(Nt*Nr);
for p = 1:Np
    tmp = spdiags(ones(Nt,1), -p, Nt, Nt);
    H_f = H_f + kron(tmp, -params.phi(:, (p-1)*Nr+1:p*Nr));
end

% blocks of Q
Q_y = H_e' * Q_eps * H_e;
Q_f = H_f' * Q_ups * H_f + Llambda' * Q_y * Llambda; 
Q_f_y = -Llambda' * Q_y; 
Q = [Q_f, Q_f_y; Q_f_y', Q_y];

% permute Q
PQP = Q(p_z, p_z); 
PQP_fymis = PQP(1:(Nr*Nt + Nmis), 1:(Nr*Nt + Nmis));
end





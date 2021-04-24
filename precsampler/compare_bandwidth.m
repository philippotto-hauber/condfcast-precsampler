clear; close all; clc; 
addpath('../sim/')

rng(1234) 

%% data

% set-up
Nt = 50;
Nh = 20; 
Nn = 10;
Nr = 1;

% generate artificial data
simdata = sim_data(Nt, Nh, Nn, Nr);

% conditional forecasts
Y_c = NaN(Nn, Nh);
Y_c(1,:) = simdata.yfore(1,:);
Y_c(2,1:Nh/2) = simdata.yfore(2,1:Nh/2);
Y = [simdata.y Y_c];

%% plot original and permuted precision matrix

% construct permutation matrix and count number of missings
p_z = p_timet(Y, Nr); 
Nmis = sum(sum(isnan(Y))); 

% permute
[P_z, P_aalphaYfore] = construct_PQP_example(simdata.params, Nt+Nh, Nmis, 1:length(p_z));
[P_z_perm, P_aalphaYfore_perm] = construct_PQP_example(simdata.params, Nt+Nh, Nmis, p_z);

% bandwidth
[bw_z_l, bw_z_u] = bandwidth(P_aalphaYfore);
[bw_z_perm_l, bw_z_perm_u] = bandwidth(P_aalphaYfore_perm);

% plot 
highl_area = (Nt+Nh)*Nr + Nn * Nh - sum(sum(~isnan(Y_c)));
figure(2);
fig = gcf;
fig.PaperOrientation = 'landscape';
subplot(1,2,1)
spy(P_z)
xlabel('')
title('$$Q_z$$','interpreter','latex','FontSize',16)
subplot(1,2,2)
spy(P_z_perm)
xlabel('')
rectangle('Position',[0 0 highl_area highl_area],...
          'FaceColor','none','EdgeColor',[0 0 0])
title('$$Q_{z_{\mathcal{P}''}}$$','interpreter','latex','FontSize',16)

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


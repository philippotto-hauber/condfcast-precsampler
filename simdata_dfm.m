clear; close all; clc;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%- This code 
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% set-up
%-------------------------------------------------------------------------%

Nt = 100;
Nh = 20; 
Nn = 20;
Nr = 2; 
Nj = 1; 
Np = 2;
Ns = 3;

%-------------------------------------------------------------------------%
% params
%-------------------------------------------------------------------------%

mean_lams = [0.6, 0.4, 0, 0];
sig_lams = [0.1, 0.1, 0.7, 0.7];
lam = mean_lams(1) + sig_lams(1) * randn(Nn, Nr);
for s = 1:Ns
    lam = [lam mean_lams(s+1) + sig_lams(s+1) * randn(Nn, Nr)];
end

Phi = [0.4 * eye(Nr) 0.1 * eye(Nr)];

Psi = -0.3 * ones(Nn, 1);

Sig_ups = eye(Nr);
Sig_eps = 0.2 + unifrnd(0.0, 0.2, Nn, 1);

%-------------------------------------------------------------------------%
% initialize mats for storage
%-------------------------------------------------------------------------%

Nburnin = 20; % sufficiently large burn-in so we don't have to worry about initalisation and can start the loop at t= max(Ns, Np, Nj)+1
y = NaN(Nn, Nburnin + Nt + Nh);
y(:, 1:Nburnin) = 0;
e = NaN(Nn, Nburnin + Nt + Nh);
e(:, 1:Nburnin) = 0;
f = NaN(Nr, Nburnin + Nt + Nh);
f(:, 1:Nburnin) = 0;

%-------------------------------------------------------------------------%
% loop over t
%-------------------------------------------------------------------------%

for t = 5:Nburnin+Nt+Nh
  f_lags = [];
  for p = 1 : Np
      f_lags = [f_lags; f(:, t-p)];
  end
  f(:, t) = Phi * f_lags + mvnrnd(zeros(Nr, 1), Sig_ups)';
  e_lags = []; Psi_diag = [];
  for j = 1:Nj
       Psi_diag = [Psi_diag diag(Psi(:, j))];
       e_lags = [e_lags; e(:, t-j)];
  end
  e(:, t) = diag(Psi) * e_lags + sqrt(Sig_eps) .* randn(Nn, 1);
  F = [];
  for s = 0:Ns
      F = [F; f(:, t-s)];
  end
  y(:, t) = lam * F + e(:, t);
end

% remove burn-in 
y = y(:, Nburnin + 1:end);
yobs = y(:, 1:Nt);
yfore = y(:, Nt+1:Nt+Nh);
e = e(:, Nburnin + 1:end);
f = f(:, Nburnin + 1:end);

%-------------------------------------------------------------------------%
% plots
%-------------------------------------------------------------------------%

figure;plot(f', 'r-'); hold on; plot([f(:, 1:Nt)'; NaN(Nh, Nr)], 'b-')
title('f')
figure;plot(y', 'r-'); hold on; plot([yobs'; NaN(Nh, Nn)], 'b-')
title('y')
tmp = corr(yobs');
figure; histogram(tmp(:));title('correlation coefficients');

%-------------------------------------------------------------------------%
% export to mat
%-------------------------------------------------------------------------%

simdata.params.lam = lam;
simdata.params.Phi = Phi;
simdata.params.Psi = Psi;
simdata.params.Sig_eps = Sig_eps;
simdata.params.Sig_ups = Sig_ups;
simdata.yobs = yobs;
simdata.yfore = yfore;
simdata.f = f;
simdata.setup.Nn = Nn;
simdata.setup.Nt = Nt;
simdata.setup.Nh = Nh;
simdata.setup.Nr = Nr;
simdata.setup.Np = Np;
simdata.setup.Ns = Ns;
simdata.setup.Nj = Nj;

save('simdata.mat', 'simdata')
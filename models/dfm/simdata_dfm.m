clear; close all; clc; 
%-------------------------------------------------------------------------%
% set-up
%-------------------------------------------------------------------------%

Nt = 100;
Nh = 50; 
Nn = 60;
Nr = 2; 
Nj = 1; 
Np = 2;
Ns = 3;

%-------------------------------------------------------------------------%
% params
%-------------------------------------------------------------------------%

mean_lams = [0.6, -0.4, 0, 0];
sig_lams = [0.1, 0.1, 0.3, 0.3];
lam = mean_lams(1) + sig_lams(1) * randn(Nn, Nr);
for s = 1:Ns
    lam = [lam mean_lams(s+1) + sig_lams(s+1) * randn(Nn, Nr)];
end

phi = [0.7 * eye(Nr), -0.2 * eye(Nr)];
sig_ups = eye(Nr);


Np_eff = max(Np, Ns+1);
Sig_f_prev = eye(Nr * Np_eff);
err = 999;
phi_comp = [phi zeros(Nr, (Np_eff - Np)*Nr); eye(Nr * (Np_eff-1)), zeros(Nr * (Np_eff-1), Nr)]; 
sig_ups_comp = zeros(Nr * Np_eff);
sig_ups_comp(1:Nr, 1:Nr) = sig_ups; 

while err > 1e-5
    Sig_f = phi_comp * Sig_f_prev * phi_comp' + sig_ups_comp;
    err = max(abs(Sig_f(:) - Sig_f_prev(:)));
    Sig_f_prev = Sig_f;
end

psi = -0.2 * ones(Nn, 1);

sig_eps = diag(lam * Sig_f(1:Nr*(Ns+1), 1:Nr*(Ns+1)) * lam') * (1-psi(1)^2) * 3/7; % 70 percent of variation explained by common component!

%-------------------------------------------------------------------------%
% initialize mats for storage
%-------------------------------------------------------------------------%

Nburnin = 20; % sufficiently large burn-in so we don't have to worry about initalisation and can start the loop at t= max(Ns, Np, Nj)+1
Y = NaN(Nn, Nburnin + Nt + Nh);
Y(:, 1:Nburnin) = 0;
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
  f(:, t) = phi * f_lags + mvnrnd(zeros(Nr, 1), sig_ups)';
  e_lags = []; Psi_diag = [];
  for j = 1:Nj
       Psi_diag = [Psi_diag diag(psi(:, j))];
       e_lags = [e_lags; e(:, t-j)];
  end
  e(:, t) = diag(psi) * e_lags + sqrt(sig_eps) .* randn(Nn, 1);
  F = [];
  for s = 0:Ns
      F = [F; f(:, t-s)];
  end
  Y(:, t) = lam * F + e(:, t);
end

% remove burn-in 
Y = Y(:, Nburnin + 1:end);
Yobs = Y(:, 1:Nt);
Yfore = Y(:, Nt+1:Nt+Nh);
e = e(:, Nburnin + 1:end);
f = f(:, Nburnin + 1:end);


%-------------------------------------------------------------------------%
% export to mat
%-------------------------------------------------------------------------%

simdata.params.lambda = lam;
simdata.params.phi = phi;
simdata.params.psi = psi;
simdata.params.sig_eps = sig_eps;
simdata.params.sig_ups = sig_ups;
simdata.Yobs = Yobs;
simdata.Yfore = Yfore;
simdata.f = f;
simdata.e = e;
simdata.setup.Nn = Nn;
simdata.setup.Nt = Nt;
simdata.setup.Nh = Nh;
simdata.setup.Nr = Nr;
simdata.setup.Np = Np;
simdata.setup.Ns = Ns;
simdata.setup.Nj = Nj;

save('simdata.mat', 'simdata')



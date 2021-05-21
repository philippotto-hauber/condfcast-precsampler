clear; close all; clc;

addpath('../../functions')
% load data
%load('simdata.mat')
tmp = importdata('C:\Users\Philipp\Documents\GitHub\condfcast-precsampler\data\vintage2006-04-05.csv');

% data and factors
%y = simdata.Yobs';
y = tmp.data; 
clear tmp

% MCMC options
options.Nburnin = 1000 ; % # of burn-ins
options.Nreplic = 1000 ; % # of replics
options.Nthin = 2 ; % store each options.thinning-th draw
options.Ndisplay = 1000 ;  % display each options.display-th iteration

% model specs
options.Nr = 1;
options.Nj = 1;
options.Ns = 3;
options.Np = 2;

draws = GibbsSampler_dfm(y, options);

% tr_r2_draws = NaN(size(draws.f, 3), 1);
% for m = 1:size(draws.f, 3)
%     f_estim = draws.f(:, :, m);
%     tr_r2_draws(m) = traceR2(f, f_estim);
% end
% 
% histogram(tr_r2_draws)
% 
% traceR2(f, median(draws.f, 3))







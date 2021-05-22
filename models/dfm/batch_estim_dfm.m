function batch_estim_dfm(v)

addpath('../../functions')
dir_in = 'C:\Users\Philipp\Documents\GitHub\condfcast-precsampler\data\vintages\';
dir_out = 'C:\Users\Philipp\Documents\Dissertation\condfcast-precsampler\models\dfm\';
% load data
tmp = importdata([dir_in, 'vintage', v, '.csv']);


offset_numcols = size(tmp.textdata, 2) - size(tmp.data, 2); % offset as there are less numeric columns!
ind_sample = logical(tmp.data(:, find(strcmp('flag_estim', tmp.textdata(1,:))) - offset_numcols));
ind_vars = find(not(contains(tmp.textdata(1,:), 'min')) & ...
                not(contains(tmp.textdata(1,:), 'med')) & ...
                not(contains(tmp.textdata(1,:), 'max')) & ...
                not(contains(tmp.textdata(1,:), 'date')) & ...
                not(contains(tmp.textdata(1,:), 'flag'))) - offset_numcols;


% data 
y = tmp.data(ind_sample, ind_vars); 
clear tmp

% MCMC options
options.Nburnin = 1000 ; % # of burn-ins
options.Nreplic = 1000 ; % # of replics
options.Nthin = 2 ; % store each options.thinning-th draw
options.Ndisplay = 1000 ;  % display each options.display-th iteration

% model specs
options.Nr = 3;
options.Nj = 1;
options.Ns = 3;
options.Np = 2;

% call GibbsSampler_dfm.m
draws = GibbsSampler_dfm(y, options);

% store draws
save([dir_out, 'draws_', v, '.mat'], 'draws')


function batch_estim_dfm(v)

addpath('../../functions')
dir_in = 'C:\Users\Philipp\Documents\GitHub\condfcast-precsampler\data\vintages\';
dir_out = 'C:\Users\Philipp\Documents\Dissertation\condfcast-precsampler\models\dfm\';

% load data
out_dfm = prepare_data(v, dir_in);

% MCMC options
out_dfm.options.Nburnin = 1000 ; % # of burn-ins
out_dfm.options.Nreplic = 1000 ; % # of replics
out_dfm.options.Nthin = 2 ; % store each options.thinning-th draw
out_dfm.options.Ndisplay = 1000 ;  % display each options.display-th iteration

% model specs
out_dfm.options.Nr = 1;
out_dfm.options.Nj = 1;
out_dfm.options.Ns = 2;
out_dfm.options.Np = 2;

% call GibbsSampler_dfm.m
out_dfm.draws = GibbsSampler_dfm(out_dfm.y_o, out_dfm.options);

% store output
save([dir_out, 'out_dfm_', v, '.mat'], 'out_dfm')


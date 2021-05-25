function estim_dfm(n_spec)

addpath('../../functions')
dir_in = '../../data/vintages/';
dir_out = 'draws/';

[v, Nr, Nj, Np, Ns] = get_specs_estim(n_spec);

% load data
out_dfm = prepare_data(v, dir_in);

% MCMC options
out_dfm.options.Nburnin = 10000 ; % # of burn-ins
out_dfm.options.Nreplic = 10000 ; % # of replics
out_dfm.options.Nthin = 2 ; % store each options.thinning-th draw
out_dfm.options.Ndisplay = 5000 ;  % display each options.display-th iteration

% model specs
out_dfm.options.Nr = Nr;
out_dfm.options.Nj = Nj;
out_dfm.options.Ns = Ns;
out_dfm.options.Np = Np;

% call GibbsSampler_dfm.m
out_dfm.draws = GibbsSampler_dfm(out_dfm.y_o, out_dfm.options);

% store output
filename = [dir_out, 'out_dfm_Nr' num2str(out_dfm.options.Nr), ...
            '_Nj', num2str(out_dfm.options.Nj), ...
            '_Np' num2str(out_dfm.options.Np), ...
            '_Ns' num2str(out_dfm.options.Ns), ...
            '_' v, '.mat'];
save(filename, 'out_dfm')


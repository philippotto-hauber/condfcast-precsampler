function [v, Nr, Nj, Np, Ns] = get_specs_estim(n_spec)

% read in list of vintages
dir_in = '../../data/';
vintages = importdata([dir_in, 'list_vintages.csv']);

% read in model spec file
dir_in = '';
model_specs = readmatrix([dir_in, 'model_specs.csv']);

ind_vs = repmat(1:length(vintages), 1, size(model_specs, 2));
ind_specs = kron(1:size(model_specs, 2), ones(1, length(vintages)));

v = vintages{ind_vs(n_spec)};
model_spec = model_specs(ind_specs(n_spec), :);
Nr = model_spec(1);
Nj = model_spec(2);
Np = model_spec(3);
Ns = model_spec(4);










function [v, model_spec, forecast_type] = get_specs_fore(n_spec)

% read in list of vintages
dir_in = '../../data/';
vintages = readmatrix([dir_in, 'list_vintages.csv']);

% read in model spec file
dir_in = '';
model_specs = readmatrix([dir_in, 'model_specs.csv']);

% forecast_types
forecast_types = {'unconditional', 'conditional (hard)', 'conditional (soft)'};

rep(1:length(vintages), length(model_specs));









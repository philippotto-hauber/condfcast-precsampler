function [v, model_spec, forecast_type] = get_specs_fore(n_spec)

% read in list of vintages
dir_in = '../../data/';
vintages = importdata([dir_in, 'list_vintages.csv']);

% read in model spec file
dir_in = '';
model_specs = readmatrix([dir_in, 'model_specs.csv']);

% forecast_types
forecast_types = {'unconditional', 'conditional_hard'};

ind_vs = repmat(1:length(vintages), 1, size(model_specs, 1) * length(forecast_types));
ind_types = repmat(kron(1:length(forecast_types), ones(1, length(vintages))), 1, size(model_specs, 1));
ind_specs = kron(1:size(model_specs, 1), ones(1, length(vintages) * length(forecast_types)));
 
v = vintages{ind_vs(n_spec)};
forecast_type = forecast_types{ind_types(n_spec)};
model_spec = ['Nr' num2str(model_specs(ind_specs(n_spec), 1)), ...
             '_Nj' num2str(model_specs(ind_specs(n_spec), 2)), ...
             '_Np' num2str(model_specs(ind_specs(n_spec), 3)), ...
             '_Ns' num2str(model_specs(ind_specs(n_spec), 4))];







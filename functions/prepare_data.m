function out = prepare_data(v, dir_data)

% load data
tmp = importdata([dir_data, 'vintage', v, '.csv']);
offset_numcols = size(tmp.textdata, 2) - size(tmp.data, 2); % offset as there are less numeric columns!
offset_numrows = size(tmp.textdata, 1) - size(tmp.data, 1); % offset as there are less numeric rows!

% y_o
ind_sample = logical(tmp.data(:, find(strcmp('flag_estim', tmp.textdata(1,:))) - offset_numcols));
ind_vars = find(not(contains(tmp.textdata(1,:), 'min')) & ...
                not(contains(tmp.textdata(1,:), 'med')) & ...
                not(contains(tmp.textdata(1,:), 'max')) & ...
                not(contains(tmp.textdata(1,:), 'date')) & ...
                not(contains(tmp.textdata(1,:), 'flag'))) - offset_numcols;
y_o = tmp.data(ind_sample, ind_vars); 

% y_c
ind_gdp_med = find(strcmp(tmp.textdata(1,:), 'med_gdp')) - offset_numcols;
ind_cpi_med = find(strcmp(tmp.textdata(1,:), 'med_cpi')) - offset_numcols;
ind_h_gdp = not(isnan(tmp.data(:, ind_gdp_med)));
ind_h_cpi = not(isnan(tmp.data(:, ind_cpi_med))); % not the same as CPI is released earlier!
ind_h = not(ind_sample); % this corresponds to ind_h_gdp!

y_c = tmp.data(ind_h, ind_vars);

ind_gdp = find(strcmp(tmp.textdata(1,:), 'gdp')) - offset_numcols;
ind_cpi = find(strcmp(tmp.textdata(1,:), 'cpi')) - offset_numcols;

y_c(find(ind_h_gdp)-find(ind_sample, 1, 'last'), ind_gdp) = tmp.data(ind_h_gdp, ind_gdp_med);
y_c(find(ind_h_cpi)-find(ind_sample, 1, 'last'), ind_cpi) = tmp.data(ind_h_cpi, ind_cpi_med);

y_c(:, setdiff(1:size(y_c, 2),[ind_gdp, ind_cpi])) = NaN; 

% y_l and y_u
ind_gdp_min = find(strcmp(tmp.textdata(1,:), 'min_gdp')) - offset_numcols;
ind_cpi_min = find(strcmp(tmp.textdata(1,:), 'min_cpi')) - offset_numcols;

y_l = NaN(size(y_c));
y_l(:, [ind_gdp, ind_cpi]) = tmp.data(ind_h, [ind_gdp_min, ind_cpi_min]);

ind_gdp_max = find(strcmp(tmp.textdata(1,:), 'max_gdp')) - offset_numcols;
ind_cpi_max = find(strcmp(tmp.textdata(1,:), 'max_cpi')) - offset_numcols;
y_u = NaN(size(y_c));
y_u(:, [ind_gdp, ind_cpi]) = tmp.data(ind_h, [ind_gdp_max, ind_cpi_max]);

% standardize and export as struct
mean_y_o = mean(y_o, 1, 'omitnan');
std_y_o = std(y_o, [], 1, 'omitnan');

out.y_o = (y_o - mean_y_o) ./ std_y_o;
out.y_c = (y_c - mean_y_o) ./ std_y_o;
out.y_l = (y_l - mean_y_o) ./ std_y_o;
out.y_u = (y_u - mean_y_o) ./ std_y_o;
out.mean_y_o = mean_y_o;
out.std_y_o = std_y_o; 

out.dates_fore = tmp.textdata(find(ind_h)+offset_numrows, 1);

% mnemonics of vars (add offset back!)
out.mnemonics = tmp.textdata(1, ind_vars+offset_numcols);





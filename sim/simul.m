function simul(n)
rng(1234) % set random seed for reproducibility

% set-up
Ng = 2; 
Nm = 1;
type_fore = {'uncond', 'cond_hard', 'cond_soft'};
Ndims = 1:6;

if isdeployed 
    maxNumCompThreads(1);
    dir_in = './../../sim-precsampler/dgp/';
    dir_out = './../../sim-precsampler/out/';
    n = str2double(n);
else
    addpath('./../precsampler/')
    addpath('CK1994/')
    addpath('DK2002/')
    addpath('./../functions/')
    dir_in = './../../../Dissertation/condfcast-precsampler/sim/dgp/';
    dir_out = './../../../Dissertation/condfcast-precsampler/sim/out test/';
end

% back out g and sampler from input arg
if n <= Ng
    g = n;
    sampler = 'CK'; 
elseif n <= Ng * 2
    g = n - Ng;
    sampler = 'DK';
elseif n <= Ng * 3
    g = n - 2 * Ng;
    sampler = 'HS'; 
end
  
% loop over dims and ftypes
for d = Ndims
    [dims, model, dims_str] = get_dims(d);
    disp('-------------------------------')
    disp([model, ' ' dims_str])
    
    load([dir_in, model, '_', dims_str, '_g_', num2str(g)]);
    if strcmp(model, 'var')
        Y_o = []; 
    else
        Y_o  = simdata.y; 
    end
    for t = 1:length(type_fore)
        Y_f = []; Y_u = []; Y_l = [];
        if strcmp(type_fore{t}, 'cond_soft')                     
            Y_f = NaN(dims.Nn, dims.Nh);
            sig = sqrt(var(simdata.y, [], 2));
            Y_u = NaN(dims.Nn, dims.Nh);                    
            Y_u(dims.ind_n, dims.ind_h) = simdata.yfore(dims.ind_n, dims.ind_h) + repmat(3 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
            Y_l = NaN(dims.Nn, dims.Nh);
            Y_l(dims.ind_n, dims.ind_h) = simdata.yfore(dims.ind_n, dims.ind_h) - repmat(3 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
        elseif strcmp(type_fore{t}, 'cond_hard')
            % conditional forecasts
            Y_f = NaN(dims.Nn, dims.Nh);
            Y_f(dims.ind_n,:) = simdata.yfore(dims.ind_n,:);
        elseif strcmp(type_fore{t}, 'uncond')
            % unconditional forecasts
            Y_f = NaN(dims.Nn, dims.Nh);
        end                        
        telapsed = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model);
        writematrix(telapsed,[dir_out, 'runtime_' sampler '_' type_fore{t} '_' model '_' dims_str '_g_' num2str(g) '.csv'])
    end
end


                    
                    




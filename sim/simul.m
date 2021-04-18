function simul(n)
rng(1234) % set random seed for reproducibility

% set-up
Ng = 10; 
Nm = 1000;
type_fore = {'uncond', 'cond_hard', 'cond_soft'};
Ndims = 1:6;
max_iter = 1e2;

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
            Y_f(dims.ind_n_hard, dims.ind_h) = simdata.yfore(dims.ind_n_hard, dims.ind_h);
            sig = sqrt(var(simdata.y, [], 2));
            Y_u = NaN(dims.Nn, dims.Nh);                    
            Y_u(dims.ind_n_soft, dims.ind_h) = simdata.yfore(dims.ind_n_soft, dims.ind_h) + repmat(1 * sig(dims.ind_n_soft, 1), 1, length(dims.ind_h));
            Y_l = NaN(dims.Nn, dims.Nh);
            Y_l(dims.ind_n_soft, dims.ind_h) = simdata.yfore(dims.ind_n_soft, dims.ind_h) - repmat(1 * sig(dims.ind_n_soft, 1), 1, length(dims.ind_h));
        elseif strcmp(type_fore{t}, 'cond_hard')
            % conditional forecasts
            Y_f = NaN(dims.Nn, dims.Nh);
            Y_f(dims.ind_n_hard,:) = simdata.yfore(dims.ind_n_hard,:);
        elseif strcmp(type_fore{t}, 'uncond')
            % unconditional forecasts
            Y_f = NaN(dims.Nn, dims.Nh);
        end   
        if strcmp(type_fore{t}, 'cond_soft')
            telapsed = timesampler_softcond(Y_o, Y_f, simdata, Nm, sampler, model);
        else
            telapsed = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model, max_iter);
        end
        writematrix(telapsed,[dir_out, 'runtime_' sampler '_' type_fore{t} '_' model '_' dims_str '_g_' num2str(g) '.csv'])
    end
end

function telapsed = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model, max_iter)

if strcmp(sampler, 'CK')    
    tic;
    for m = 1:Nm
        [T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);
        [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
    end
    telapsed = toc; 
elseif strcmp(sampler, 'DK')
    tic;
    for m = 1:Nm
        [T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);
        [sdraw, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
    end
    telapsed = toc; 
elseif strcmp(sampler, 'HS')
    if strcmp(model, 'var') % no states!
        p_z = p_timet([Y_o, Y_f], 0);
    else % account for states when permuting by time-t
        p_z = p_timet([Y_o, Y_f], size(simdata.aalpha, 1));
    end
    tic; 
    for m = 1:Nm
        [sdraw, Ydraw] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z, max_iter, model);
    end
    telapsed = toc; 
end

function telapsed = timesampler_softcond(Y_o, Y_f, simdata, Nm, sampler, model)

if strcmp(sampler, 'CK')    
    tic;
    [T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);
    store_Ydraw = simsmooth_CK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Nm);
    telapsed = toc; 
elseif strcmp(sampler, 'DK')
    tic;
    [T, Z, H, R, Q, a1, P1] = get_statespaceparams(simdata.params, simdata.y, model);
    store_Ydraw = simsmooth_DK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Nm);
    telapsed = toc; 
elseif strcmp(sampler, 'HS')
    if strcmp(model, 'var') % no states!
        p_z = p_timet([Y_o, Y_f], 0);
    else % account for states when permuting by time-t
        p_z = p_timet([Y_o, Y_f], size(simdata.aalpha, 1));
    end
    tic;
    store_Ydraw = simsmooth_HS_oversample(Y_o, Y_f, simdata.params, p_z, Nm, model);
    telapsed = toc; 
end




                    
                    




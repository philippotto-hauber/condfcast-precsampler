function simul(n)
rng(1234) % set random seed for reproducibility

% set-up
Nm = 100; 
max_iter = 100;

if isdeployed 
    maxNumCompThreads(1);
    dir_in = './../../sim-precsampler/dgp/';
    dir_out = './../../sim-precsampler/out/';
    n = str2double(n);
    Nmodels = 1:6;
    Nhs = [5, 20, 50];
    Nconds = [10, 50, 75];
else
    addpath('./../precsampler/')
    addpath('CK1994/')
    addpath('DK2002/')
    addpath('./../functions/')
    dir_in = './dgp/';
    dir_out = './out local/';
    Nmodels = 6;
    Nhs = [5, 20, 50];
    Nconds = [10, 50, 75];
end

% back out g, sampler and type_fore
[g, sampler, type_fore] = get_g_sampler_typefore(n);

% loop over dims and ftypes
for Nh = Nhs
    for Ncond = Nconds        
        for m = Nmodels           
            [dims, flag_modelclass, dims_str] = get_dims(m, Nh, Ncond);
            %disp('-------------------------------')
            %disp([flag_modelclass, ' ' dims_str, '_Ncond_' num2str(Ncond)])    
            load([dir_in, flag_modelclass, '_', dims_str, '_g_', num2str(g)]);
            if strcmp(flag_modelclass, 'var')
                Y_o = []; 
            else
                Y_o  = simdata.y; 
            end
            if strcmp(type_fore, 'cond_soft') || strcmp(type_fore, 'cond_hard')       
                Y_f = NaN(dims.Nn, dims.Nh);
                Y_f(1:dims.Ncond,:) = simdata.yfore(1:dims.Ncond,:);
            elseif strcmp(type_fore, 'uncond')
                % unconditional forecasts
                Y_f = NaN(dims.Nn, dims.Nh);
            end   
            if strcmp(type_fore, 'cond_soft')
                telapsed = timesampler_softcond(Y_o, Y_f, simdata, Nm, sampler, flag_modelclass);
            else
                telapsed = timesamplers(Y_o, Y_f, [], [], simdata, Nm, sampler, flag_modelclass, max_iter);
            end
            writematrix(telapsed,[dir_out, 'runtime_' sampler '_' type_fore '_' flag_modelclass '_' dims_str '_Ncond_' num2str(Ncond) '_g_' num2str(g) '.csv'])
        end
    end
end

function telapsed = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model, max_iter)

if strcmp(sampler, 'CK') 
    
    f = @() tmp_CK(simdata.params, simdata.y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_CK(simdata.params, simdata.y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm);
%     telapsed = cputime - tstart;

elseif strcmp(sampler, 'DK')
    
    f = @() tmp_DK(simdata.params, simdata.y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_DK(simdata.params, simdata.y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm);
%     telapsed = cputime - tstart;
    
elseif strcmp(sampler, 'HS')
    if strcmp(model, 'var') % no states!
        p_z = p_timet([Y_o, Y_f], 0);
    else % account for states when permuting by time-t
        p_z = p_timet([Y_o, Y_f], size(simdata.aalpha, 1));
    end
    f = @() tmp_HS(simdata.params, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm, p_z);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_HS(simdata.params, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm, size(simdata.aalpha, 1));
%     telapsed = cputime - tstart;
    
end


function tmp_CK(params, y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm)
%     for m = 1:Nm
        [T, Z, H, R, Q, a1, P1] = get_statespaceparams(params, y, model);
        [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
%     end
    
function tmp_DK(params, y, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm)
%     for m = 1:Nm
        [T, Z, H, R, Q, a1, P1] = get_statespaceparams(params, y, model);
        [sdraw, Ydraw] = simsmooth_DK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, a1, P1, max_iter);
%     end
    
function tmp_HS(params, model, Y_o, Y_f, Y_u, Y_l, max_iter, Nm, p_z)
%     for m = 1:Nm
        [sdraw, Ydraw] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, params, p_z, max_iter, model);
%     end

function telapsed = timesampler_softcond(Y_o, Y_f, simdata, Nm, sampler, model)

if strcmp(sampler, 'CK')    
    f = @() tmp_CK_oversample(simdata.params, simdata.y, model, Y_o, Y_f, Nm);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_CK_oversample(simdata.params, simdata.y, model, Y_o, Y_f, Nm);
%     telapsed = cputime - tstart;
    
elseif strcmp(sampler, 'DK')
    f = @() tmp_DK_oversample(simdata.params, simdata.y, model, Y_o, Y_f, Nm);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_DK_oversample(simdata.params, simdata.y, model, Y_o, Y_f, Nm);
%     telapsed = cputime - tstart;
elseif strcmp(sampler, 'HS')
    if strcmp(model, 'var') % no states!
        p_z = p_timet([Y_o, Y_f], 0);
    else % account for states when permuting by time-t
        p_z = p_timet([Y_o, Y_f], size(simdata.aalpha, 1));
    end
    f = @() tmp_HS_oversample(simdata.params, model, Y_o, Y_f, Nm, p_z);
    telapsed = timeit(f);
%     tstart = cputime;
%     tmp_HS_oversample(simdata.params, model, Y_o, Y_f, Nm, size(simdata.aalpha, 1));
%     telapsed = cputime - tstart;
end

function tmp_CK_oversample(params, y, model, Y_o, Y_f, Nm)
    [T, Z, H, R, Q, a1, P1] = get_statespaceparams(params, y, model);
    Ydraw = simsmooth_CK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Nm);

    
function tmp_DK_oversample(params, y, model, Y_o, Y_f, Nm)
    [T, Z, H, R, Q, a1, P1] = get_statespaceparams(params, y, model);
    Ydraw = simsmooth_DK_oversample(Y_o, Y_f, T, Z, H, R, Q, a1, P1, Nm);
    
function tmp_HS_oversample(params, model, Y_o, Y_f, Nm, p_z)
    store_Ydraw = simsmooth_HS_oversample(Y_o, Y_f, params, p_z, Nm, model);



                    
                    




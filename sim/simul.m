function simul()
rng(1234) % set random seed for reproducibility

dir_dgp = './../../sim-precsampler/dgp/';
dir_out = './../../sim-precsampler/out/';

if not(isdeployed) % compile with mcc -m batch_sim.m -a ./CK1994 -a ./DK2002 -a ./../precsampler -a ./../functions
addpath('./../precsampler/')
addpath('CK1994/')
addpath('DK2002/')
addpath('./../functions/')
dir_dgp = './../../../Dissertation/condfcast-precsampler/sim/dgp test/';
dir_out = './../../../Dissertation/condfcast-precsampler/sim/out test/';
end

 
Nm = 10;
Ng = 2;    

type_fore = {'uncond', 'cond_hard', 'cond_soft'};
samplers = {'CK', 'DK', 'HS',}; % {'CK', 'DK', 'HS'}

Ndims = 1:6; 
for d = Ndims
    [dims, model, dims_str] = get_dims(d);
    disp('-------------------------------')
    disp([model, ' ' dims_str])
    % simulate Ng dgps
    for g = 1:Ng
        simdata = generate_data(dims, model);
        save([dir_dgp, 'dgp_', num2str(g)], 'simdata');
    end
    for s = 1:length(samplers)
        sampler = samplers{s};
        for t = 1:length(type_fore)
            telapsed = NaN(Ng, 1); 
            for g = 1:Ng
                % clear vars
                Y_f = []; Y_l = []; Y_u = [];
                % load data
                load([dir_dgp, 'dgp_' num2str(g)]);
                if strcmp(model, 'var')
                    Y_o = []; 
                else
                    Y_o  = simdata.y; 
                end
                if strcmp(type_fore{t}, 'cond_soft')                     
                    Y_f = NaN(dims.Nn, dims.Nh);
                    sig = sqrt(var(simdata.y, [], 2));
                    Y_u = NaN(dims.Nn, dims.Nh);                    
                    Y_u(dims.ind_n, dims.ind_h) = simdata.yfore(dims.ind_n, dims.ind_h) + repmat(2 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
                    Y_l = NaN(dims.Nn, dims.Nh);
                    Y_l(dims.ind_n, dims.ind_h) = simdata.yfore(dims.ind_n, dims.ind_h) - repmat(2 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
                elseif strcmp(type_fore{t}, 'cond_hard')
                    % conditional forecasts
                    Y_f = NaN(dims.Nn, dims.Nh);
                    Y_f(dims.ind_n,:) = simdata.yfore(dims.ind_n,:);
                elseif strcmp(type_fore{t}, 'uncond')
                    % unconditional forecasts
                    Y_f = NaN(dims.Nn, dims.Nh);
                end                        
                telapsed(g, 1) = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model);
            end
            writematrix(telapsed,[dir_out, 'runtime_' sampler '_' type_fore{t} '_' dims_str '.csv'])
        end
    end
end

                    
                    




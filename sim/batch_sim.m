clear;
rng(1234) % set random seed for reproducibility

addpath('../precsampler/')
addpath('CK1994/')
addpath('DK2002/')

dir_dgp = './dgp/';
dir_out = './out/'; 
Nm = 1000;
Ng_softcond = 1;
Ng = 1;    

type_fore = {'uncond', 'cond_hard', 'cond_soft'};
samplers = {'CK', 'DK', 'HS'}; % {'HS', 'CK', 'DK'}
model = 'ssm';
Ndims = 4; 
for d = 1:Ndims
    [dims, dims_str] = get_dims(d);
    % simulate Ng dgps
    for g = 1:max(Ng_softcond, Ng)
        simdata = generate_data(dims, model);
        save([dir_dgp, 'dgp_', num2str(g)], 'simdata');
    end
    for s = 1:length(samplers)
        sampler = samplers{s};
        for t = 1:length(type_fore)
            if strcmp(type_fore{t}, 'cond_soft')
                Ng_tmp = Ng_softcond;
            else
                Ng_tmp = Ng; 
            end
            telapsed = NaN(Ng_tmp, 1); 
            for g = 1:Ng_tmp
                % clear vars
                Y_f = []; Y_l = []; Y_u = [];
                % load data
                load([dir_dgp, 'dgp_' num2str(g)]);
                Y_o  = simdata.y; 
                if strcmp(type_fore{t}, 'cond_soft')                     
                    Y_f = NaN(dims.Nn, dims.Nh);
                    sig = sqrt(var(simdata.y, [], 2));
                    Y_u = NaN(dims.Nn, dims.Nh);                    
                    Y_u(dims.ind_n, :) = simdata.yfore(dims.ind_n, dims.ind_h) + repmat(2 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
                    Y_l = NaN(dims.Nn, dims.Nh);
                    Y_l(dims.ind_n, :) = simdata.yfore(dims.ind_n, dims.ind_h) - repmat(2 * sig(dims.ind_n, 1), 1, length(dims.ind_h));
                elseif strcmp(type_fore{t}, 'cond_hard')
                    % conditional forecasts
                    Y_f = NaN(dims.Nn, dims.Nh);
                    Y_f(1:dims.Nn/10,1:dims.Nh) = simdata.yfore(1:dims.Nn/10,1:dims.Nh);
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

                    
                    




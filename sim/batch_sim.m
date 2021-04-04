clear;

addpath('../precsampler/')
addpath('CK1994/')
addpath('DK2002/')

Ng = 2;
Nm = 100; 

type_fore = {'uncond', 'cond_hard'};
samplers = {'CK', 'DK', 'HS'}; % {'HS', 'CK', 'DK'}
model = 'ssm';
dims1.Nt = 100;
dims1.Nh = 20; 
dims1.Nn = 20;
dims1.Ns = 2;
dims2.Nt = 100;
dims2.Nh = 20; 
dims2.Nn = 100;
dims2.Ns = 2;
dims3.Nt = 100;
dims3.Nh = 20; 
dims3.Nn = 100;
dims3.Ns = 20; 
dims4.Nt = 100;
dims4.Nh = 20; 
dims4.Nn = 10;
dims4.Ns = 25; 
specs = {dims1, dims2, dims3, dims4};
for d = 1:length(specs)
    dims = specs{d};
    for s = 1:length(samplers)
        sampler = samplers{s};
        for t = 1:length(type_fore)
            telapsed = NaN(Ng, 1); 
            for g = 1:Ng
                % simulate data
                simdata = generate_data(dims, model);
                Y_o  = simdata.y; 
                if strcmp(type_fore{t}, 'cond_soft')                     
                    Y = [simdata.y];
                    sig = sqrt(var(simdata.y, [], 2));
                    Y_u = NaN(dims.Nn, dims.Nh);
                    Y_u(1:Nn/10,1:dims.Nh/4) = simdata.yfore(1:dims.Nn/10,1:dims.Nh/4) + repmat(2 * sig(1:dims.Nn/10, 1), 1, dims.Nh/4);
                    Y_l = NaN(dims.Nn, dims.Nh);
                    Y_l(1:dims.Nn/10,1:dims.Nh/4) = simdata.yfore(1:dims.Nn/10,1:dims.Nh/4) - repmat(2 * sig(1:dims.Nn/10, 1), 1, dims.Nh/4);
                elseif strcmp(type_fore{t}, 'cond_hard')
                    % conditional forecasts
                    Y_c = NaN(dims.Nn, dims.Nh);
                    Y_c(1:dims.Nn/10,1:dims.Nh/4) = simdata.yfore(1:dims.Nn/10,1:dims.Nh/4);
                    Y = [simdata.y Y_c];
                elseif strcmp(type_fore{t}, 'uncond')
                    % unconditional forecasts
                    Y_f = NaN(dims.Nn, dims.Nh);
                    Y_u = [];
                    Y_l = [];
                end                        
                telapsed(g, 1) = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model);
            end
            writematrix(telapsed,['runtime_' sampler '_' type_fore{t} '_' num2str(dims.Nn) '_' num2str(dims.Ns) '.csv'])
            if strcmp(type_fore{t}, 'cond_soft')   
                writematrix(iter_count,['iter_' sampler '_' num2str(dims.Nn) '_' num2str(dims.Ns) '.csv'])
            end
        end
    end
end

                    
                    




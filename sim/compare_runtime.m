clear;

addpath('../precsampler/')

Ng = 10;
Nm = 100; 
Nt = 100;
Nh = 20;

Nns = [20, 100];
Nrs = [2, 10];

type_fore = {'uncond', 'cond_hard', 'cond_soft'};
sampler = {'HS'}; % {'HS', 'CK', 'DK'}
for Nn = Nns
    for Nr = Nrs
        for s = 1:length(sampler)
            for t = 1:length(type_fore)
                telapsed = NaN(Ng, 1); 
                if strcmp(type_fore{t}, 'cond_soft') 
                    iter_count = NaN(Ng, Nm);
                end
                for g = 1:Ng
                    % simulate data
                    simdata = generate_data(Nt, Nh, Nn, Nr);

                    if strcmp(type_fore{t}, 'cond_soft')                     
                        Y = [simdata.y];
                        sig = sqrt(var(simdata.y, [], 2));
                        Y_u = NaN(Nn, Nh);
                        Y_u(1:Nn/10,1:Nh/4) = simdata.yfore(1:Nn/10,1:Nh/4) + repmat(2 * sig(1:Nn/10, 1), 1, Nh/4);
                        Y_l = NaN(Nn, Nh);
                        Y_l(1:Nn/10,1:Nh/4) = simdata.yfore(1:Nn/10,1:Nh/4) - repmat(2 * sig(1:Nn/10, 1), 1, Nh/4);
                        p_z = p_timet([Y, NaN(Nn, Nh)], Nr);
                        max_iter = 5000;
                        m = 1; 
                        tstart = tic;                        
                        while m < Nm
                            [fdraw, Ydraw, iter] = sample_z_softcond(Y, Nh, Y_l, Y_u, simdata.params, p_z, max_iter);
                            if iter < max_iter
                                m = m + 1;
                            end
                        end
                        telapsed(g, 1) = toc(tstart);
                    elseif strcmp(type_fore{t}, 'cond_hard')
                        % conditional forecasts
                        Y_c = NaN(Nn, Nh);
                        Y_c(1:Nn/10,1:Nh/4) = simdata.yfore(1:Nn/10,1:Nh/4);
                        Y = [simdata.y Y_c];
                        p_z = p_timet(Y, Nr);
                        
                        tstart = tic;
                        for m = 1:Nm
                            [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
                        end
                        telapsed(g, 1) = toc(tstart);
                    elseif strcmp(type_fore{t}, 'uncond')
                        % unconditional forecasts
                        Y = [simdata.y NaN(Nn, Nh)];
                        p_z = p_timet(Y, Nr);
                        
                        tstart = tic;
                        for m = 1:Nm
                            [fdraw, Ydraw] = sample_z(Y, simdata.params, p_z);
                        end
                        telapsed(g, 1) = toc(tstart);
                    end
                end
                writematrix(telapsed,['runtime_' sampler{s} '_' type_fore{t} '_' num2str(Nn) '_' num2str(Nr) '.csv'])
                if strcmp(type_fore{t}, 'cond_soft')   
                    writematrix(iter_count,['iter_' sampler{s} '_' num2str(Nn) '_' num2str(Nr) '.csv'])
                end
            end
        end
    end
end
                    
                    




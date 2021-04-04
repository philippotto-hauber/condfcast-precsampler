function telapsed = timesamplers(Y_o, Y_f, Y_u, Y_l, simdata, Nm, sampler, model)
max_iter = 1e4;

if strcmp(sampler, 'CK')    
    tic;
    for m = 1:Nm
        [T, Z, H, R, Q, s0, P0] = get_statespaceparams(simdata, model);
        [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0, max_iter);
    end
    telapsed = toc; 
elseif strcmp(sampler, 'DK')
    tic;
    for m = 1:Nm
        [T, Z, H, R, Q, s0, P0] = get_statespaceparams(simdata, model);
        [sdraw, Ydraw] = simsmooth_CK(Y_o, Y_f, Y_u, Y_l, T, Z, H, R, Q, s0, P0, max_iter);
    end
    telapsed = toc; 
elseif strcmp(sampler, 'HS')
    tic;
    p_z = p_timet([Y_o, Y_f], size(simdata.aalpha, 1));
    for m = 1:Nm
        [sdraw, Ydraw] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, simdata.params, p_z, max_iter);
    end
    telapsed = toc; 
end


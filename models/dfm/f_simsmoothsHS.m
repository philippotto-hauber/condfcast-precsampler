function [f, Yplus] = f_simsmoothsHS(Y_o, Y_f, phi, Omega, lam, psi, sig2, p_z, Nsample)

    % params
    params.lambda = lam;
    params.phi = phi;
    params.psi = psi; 
    params.sig_eps = sig2;
    params.sig_ups = Omega; 
    
    % vectorized yobs, removing missings
    Y = [Y_o; Y_f];
    y = vec(Y'); 
    yobs = y(~isnan(y),1); 
    Nobs = length(yobs);
    Nmis = sum(isnan(y)); % length(y) - Nobs;
    
    NtNh = size(Y, 1);
    Ns = size(Omega, 1); % # of factors
    Nn = size(Y, 2); 
    
    % precision matrix Q
    [PQP_fymis, PQP_fymis_yobs] = construct_PQP(params, NtNh, Nmis, p_z, 'ssm');
    
    % posterior moments
    chol_PQP_fymis = chol(PQP_fymis, 'lower'); 
    b_fymis = rue_held_alg2_1(chol_PQP_fymis, -PQP_fymis_yobs * yobs);
        
    % joint draw of f, ymis
    z_draw = NaN(size(b_fymis, 1)+ Nobs, 1);
    if Nsample == 1
        fymis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis); 
        z_draw(p_z, :) = [fymis_draw; yobs]; % reverse permutation => z = [vec(f); vec([Y_o, Y_f])]!
        f = reshape(z_draw(1:NtNh*Ns, :), Ns, NtNh)'; 
        Yplus = reshape(z_draw(NtNh*Ns+1:end, :), Nn, NtNh)';
    else
        f = NaN(NtNh, Ns, Nsample);
        Yplus = NaN(NtNh, Nn, Nsample);
        for m = 1:Nsample
            fymis_draw = rue_held_alg2_4(chol_PQP_fymis, b_fymis); 
            z_draw(p_z, :) = [fymis_draw; yobs]; % reverse permutation => z = [vec(f); vec([Y_o, Y_f])]!
            f(:, :, m) = reshape(z_draw(1:NtNh*Ns, :), Ns, NtNh)'; 
            Yplus(:, :, m) = reshape(z_draw(NtNh*Ns+1:end, :), Nn, NtNh)';
        end        
    end
    
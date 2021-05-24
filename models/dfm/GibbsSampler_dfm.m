function draws = GibbsSampler_dfm(y, options)

% additional model-based "options"
[options.Nt, options.Nn] = size(y);

% priors
priors.q0_phi = minnprior(0.2, 0.1, 2, options.Nr, options.Np);
priors.q0_lam = ones(options.Nr*(options.Ns+1), 1);
priors.q0_psi = ones(options.Nj, 1);
priors.nu0 = 3;
priors.S0 = 0.5; 

% permutation matrix
p_z = p_timet(y', options.Nr);

% initialize struct to store draws
draws.lam = NaN(options.Nn, options.Nr * (options.Ns+1), options.Nreplic);
draws.phi = NaN(options.Nr, options.Nr * options.Np, options.Nreplic);
draws.psi = NaN(options.Nn, options.Nj, options.Nreplic);
draws.sig2 = NaN(options.Nn, options.Nreplic);

% starting values
[lam, phi, psi, sig2] = f_startingvalues(y, options);
Omega = eye(options.Nr); 

% hyperparams for HS
hyperparams.lam2 = ones(options.Nn,options.Nr * (options.Ns+1));
hyperparams.mu = nan(options.Nn,options.Nr * (options.Ns+1));
for i=1:options.Nn
    for j=1:options.Nr * (options.Ns+1)
        hyperparams.mu(i,j) = mean(1./gamrnd(1,1./(1+1/hyperparams.lam2(i,j)),1,1000)); 
    end
end
hyperparams.tau2 = 1 ; 
hyperparams.xi = mean(1./gamrnd(1,1./(1+1/hyperparams.tau2),1,1000));
hyperparams.eta2 = ones(options.Nn,options.Nr * (options.Ns+1));
hyperparams.z = ones(options.Nn,options.Nr * (options.Ns+1));

for m = 1:options.Nburnin+options.Nreplic*options.Nthin
    if mod(m,options.Ndisplay)==0
            disp('Number of iterations');
            disp(m);
            disp('-------------------------------------------')
            disp('-------------------------------------------')
    end
    
    
    % sample states (and missing obs) given params
    %-----------------------------------
    % sample factors and missing obs
    [f, yplus] = f_sample_f_ymis(y, phi, Omega, lam, psi, sig2, p_z);


    % sample params given states
    %-----------------------------------

    % loadings
    [lam, e] = f_sample_lam(yplus, f, sig2, psi, hyperparams, options.Ns);
    
    hyperparams = f_update_hyperparams(hyperparams, lam, options.Nn, options.Nr * (options.Ns+1));

    % psi and sig2_eps
    if options.Nj > 0
        [psi, eps] = f_sample_psi(e, psi, sig2, options.Nj, priors.q0_psi);
        sig2 = f_sample_sig2(eps, sig2, priors.nu0, priors.S0);
    else % e = eps
        sig2 = f_sample_sig2(e, sig2, priors.nu0, priors.S0);
    end

    % factor VAR
    [phi, Omega] = f_sample_phi(f, options.Np, Omega, priors.q0_phi);
    
    % store draws
    %-----------------------------------
    
    if m > options.Nburnin && mod(m - options.Nburnin,options.Nthin) == 0  
        draws.lam(:, :, (m - options.Nburnin)/options.Nthin) = lam;
        draws.phi(:, :, (m - options.Nburnin)/options.Nthin) = phi;
        draws.psi(:, :, (m - options.Nburnin)/options.Nthin) = psi;
        draws.sig2(:, (m - options.Nburnin)/options.Nthin) = sig2;
    end    
end


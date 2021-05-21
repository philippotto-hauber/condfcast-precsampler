function sig2 = f_sample_sig2(eps, sig2, nu0, S0)

Nobs = size(eps, 1); 
for i = 1:size(eps, 2)
    sig2(i) = 1 / gamrnd(nu0 + Nobs/2, 1 / (S0 + eps(:, i)' * eps(:, i) / 2));   
end


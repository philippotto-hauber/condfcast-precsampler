function y = f_sample_truncNorm(m, sig, y_low, y_upp)

tmp = normcdf(y_low, m, sig) + ...
                rand() * (normcdf(y_upp, m, sig) - normcdf(y_low, m, sig));
            
y = norminv(tmp, m, sig);





function trR2 = traceR2(F, F_hat)

P_f_estim = F_hat * inv(F_hat'*F_hat) * F_hat';
trR2 = trace(F' * P_f_estim * F) / trace(F' * F);


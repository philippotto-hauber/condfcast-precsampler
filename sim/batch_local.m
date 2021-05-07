clear; close all; clc;

Ng = 10;
Nsampler = 3;
Ntypes = 3;
Nsim = Ng * Nsampler * Ntypes;
for nsampler = 1:Nsampler
    tmp_sampler = (nsampler-1)*Ntypes*Ng;
    for ntype = 1:Ntypes
        tmp_type = (ntype-1) * Ng;
        for g = 1:Ng
            disp(tmp_sampler + tmp_type + g)
            simul(tmp_sampler + tmp_type + g);
        end
    end
end
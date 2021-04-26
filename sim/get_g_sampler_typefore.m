function [g, sampler, type_fore] = get_g_sampler_typefore(n)

Ng = 3;
samplers = {'CK', 'DK', 'HS'};
type_fores = {'uncond', 'cond_hard', 'cond_soft'};

% calculate combinations of specifications
Ng_tmp = repmat(1:Ng, 1, length(samplers) * length(type_fores)) ; 
Nsamplers_tmp = repmat(kron(1:length(samplers), ones(1, length(1:Ng))), 1 , length(type_fores));
Ntypes_tmp = kron(1:length(type_fores), ones(1, length(1:Ng) * length(samplers)));

% back out specs for n

g = Ng_tmp(n);
switch Nsamplers_tmp(n)
    case 1
        sampler = 'CK';
    case 2
        sampler = 'DK';
    case 3
        sampler = 'HS';
end

switch Ntypes_tmp(n)
    case 1
        type_fore = 'uncond';
    case 2
        type_fore = 'cond_hard';
    case 3
        type_fore = 'cond_soft';
end




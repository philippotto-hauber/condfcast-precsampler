function p = p_timet(Yobs, Nr)
%------------------------------------------------------------------------ %
% This function constructs time-t permutation matrix, ordering states and 
% missing obs by time periods. 
% If y = [f_1, f_2, ..., f_T, y_1, y_2, ..., y_T] where y_t is Nn x 1, then 
% py = [f_1, y^m_1, f_2, y^m_2, ..., f_T, y^m_T, y^o_1, y^o_2, ..., y^o_T].
% Input is the N x T matrix of observables (with missing entries) and the
% number of states, Nr.
% Output is the permutation index p_z.
%---------------------
% Example: 
% A = randn(100);
% PAP = A(p, p);
% Acheck = NaN(100);
% Acheck(r, r) = PAP;
% all(A == Acheck, 'all')
%---------------------
% Note that reversing the permutation can also be achieved by
% Acheck = PAP(p, p);
% Therefore, the function only returns p!
%------------------------------------------------------------------------ %

[Nn, Nt] = size(Yobs);
r_fac = [];
r_y = [];
Nmis = sum(sum(isnan(Yobs)));
counter_t = 0;
counter_xobs = Nmis + Nt * Nr; 
for t=1:Nt
    % factors
    r_fac = [r_fac; counter_t + (1:Nr)'];
    counter_t = counter_t + Nr; 
    
    % missing obs
    for i = 1:Nn
        if isnan(Yobs(i, t))
            counter_t = counter_t + 1;
            r_y = [r_y; counter_t];
            
        else
            counter_xobs = counter_xobs + 1;
            r_y = [r_y; counter_xobs];            
        end
    end
end  

r = [r_fac; r_y];
p(r) = 1:length(r);



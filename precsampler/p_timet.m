function p_z = p_timet(Yobs, Nr)

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
p_z(r) = 1:length(r);



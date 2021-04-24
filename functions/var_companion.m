function [F, R, Q] = var_companion(Phi, Omeg)
% back out dims
Nn = size(Phi, 1);
Np = size(Phi, 2) / Nn; 

% companion form
F = [Phi; eye((Np-1)*Nn) zeros((Np-1)*Nn, Nn)]; 
R = zeros(Nn*Np, Nn);
R(1:Nn, 1:Nn) = eye(Nn); 
Q = Omeg; 


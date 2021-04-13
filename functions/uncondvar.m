function Sig = uncondvar(Phi, Omeg)
%- This function calculates the unconditional variance of the VAR:
%_ y_t = c + phi_1 y_t-1 + ... + phi_p y_t-p + e_t; e_t ~ N(0, Omeg).
%_ It is given by Sig = F * Sig * F' + Q, where F and Q are the companion
% form parameters of the VAR. See Hamilton (1994, pp. 264-265).
% Input: Nn x Nn*Np matrix of coefficients Phi = [phi1, ..., phi_p] 
%        Nn x Nn covariance matrix of VAR innovations
% Output: Nn*Np x Nn*Np unconditional covariance matrix Sig

% back out dims
Nn = size(Phi, 1);
Np = size(Phi, 2) / Nn; 

% companion form
[F, Q] = var_companion(Phi, Omeg);

% solve for Sig
A = kron(F, F); % eqn. 10.2.17
Sig = reshape((eye((Nn*Np)^2) - A) \ Q(:), Nn*Np, Nn*Np); % eqn. 10.2.18


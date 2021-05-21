function q0_phi = minnprior(pi1, pi2, pi3, Nvars, Nlags)
% function returns the prior precision of the Minnesota prior given the
% following hyperparamter:
% pi1: hyperparameter governing overall shrinkage
% pi2: hyperparameter governing shrinkage of lags belonging to other variables
% pi3: hyperparameter governing the degree of decay
% output is a Nvars^2*Nlags x 1 vector containing the diagonal elements of
% the prior precision matrix

temp = NaN(Nvars,Nvars,Nlags);
for p=1:Nlags
    % shrink coefficient on other lags by pi2!
    temp(1:Nvars,1:Nvars,p) = (pi2/(p^pi3))^(-1); % -> precision, not variance!
    for n=1:Nvars
        % shrink coefficient on own lags by pi1!
        temp(n,n,p) = (pi1/(p^pi3))^(-1); % -> precision, not variance!           
    end
end

q0_phi = f_vec(reshape(temp,Nvars,Nvars*Nlags)'); % convert temp to RxR*P matrix, then take transpose and vectorize to make conformable with f_samplephi_f!!!         


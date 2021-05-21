function [bet, e] = f_linreg(y, X, Q_e, q0_bet)
% sample bet from linear regression
% y = X bet + e; e ~ N(0, Q_e)
% prior precision of bet: diag(q0_bet)
% prior mean equals zero!

XtQ_e = X' * Q_e;
Q_bet = diag(q0_bet) + XtQ_e * X;
chol_Q = chol(Q_bet, 'lower');
m_bet = rue_held_alg2_1(chol_Q, XtQ_e * y);
bet = rue_held_alg2_4(chol_Q, m_bet);
e = y - X * bet;


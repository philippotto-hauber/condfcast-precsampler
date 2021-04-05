clear; close all; 
% test VAR code

addpath('./CK1994')
addpath('../precsampler')
rng(1234) % set random seed for reproducibility
model = 'var'; 

dims.Nt = 50; % # of in-sample observations
dims.Nn = 3; % # of variables
dims.Np = 2; % # 
dims.Nh = 10; 

simdata = generate_data(dims, model);
Y_o = simdata.y(:, end-dims.Np+1:end);
Y_f = NaN(dims.Nn, dims.Nh);
Y_u = [];
Y_l = []; 

[fdraw, Ydraw] = simsmooth_HS(Y_o, Y_f, Y_l, Y_u, params, p_z, max_iter);




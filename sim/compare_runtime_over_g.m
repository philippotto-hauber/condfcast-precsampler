clear; close all; clc;
addpath('out local/')
str_sampler = 'HS';
str_model = 'var_Nn_100_Np_4';
str_ftype = 'cond_hard';
str_Nh = 'Nh_50';
str_Ncond = 'Ncond_10';
Ng = 10;
for g = 1:Ng
    tmp = importdata(['runtime_', str_sampler, '_', ...
                                  str_ftype, '_', ...
                                  str_model, '_', ...
                                  str_Nh, '_', ...
                                  str_Ncond, '_',...
                                  'g_', num2str(g), '.csv']);
    disp(tmp)
end
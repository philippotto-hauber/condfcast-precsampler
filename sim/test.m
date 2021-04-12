% test matlab from terminal on HPC server
function test_slurm()
x = 2;
y = 5;

disp('The result is...')
x+y

save('out.mat')

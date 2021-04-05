function [dims, dims_str] = get_dims(n)
dims.Nt = 100;
dims.Nh = 5; 
switch(n)
    case 1 % small factor model
        dims.Nn = 20;
        dims.Ns = 2;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
   case 2 % large factor model
        dims.Nn = 100;
        dims.Ns = 2;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
  case 3 % large N, T factor model
        dims.Nn = 100;
        dims.Ns = 10;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
end

dims.ind_n = 1:dims.Nn/2;
dims.ind_h = 1:dims.Nh; 



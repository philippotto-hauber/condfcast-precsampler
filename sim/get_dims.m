function [dims, dims_str] = get_dims(n)

switch(n)
    case 1
        dims.Nt = 100;
        dims.Nh = 5; 
        dims.Nn = 20;
        dims.Ns = 2;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
   case 2
        dims.Nt = 100;
        dims.Nh = 5; 
        dims.Nn = 100;
        dims.Ns = 2;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
  case 3
        dims.Nt = 100;
        dims.Nh = 5; 
        dims.Nn = 100;
        dims.Ns = 20;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
   case 4
        dims.Nt = 100;
        dims.Nh = 5; 
        dims.Nn = 20;
        dims.Ns = 25;
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
end



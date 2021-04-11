function [dims, model, dims_str] = get_dims(n)
dims.Nt = 100;
dims.Nh = 5; 

switch(n)
    case 1 % small factor model
        dims.Nn = 20;
        dims.Ns = 2;
        dims.ind_n = 1:dims.Nn/10;
        dims.ind_h = 1; 
        model = 'ssm'; % actually a dfm but called ssm in the functions
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
               
        
   case 2 % large factor model
        dims.Nn = 100;
        dims.Ns = 2;   
        dims.ind_n = 1:dims.Nn/10;
        dims.ind_h = 1; 
        model = 'ssm'; % actually a dfm but called ssm in the functions
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
  case 3 % large N, T factor model
        dims.Nn = 100;
        dims.Ns = 10;  
        dims.ind_n = 1:dims.Nn/10;
        dims.ind_h = 1; 
        model = 'ssm'; % actually a dfm but called ssm in the functions
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Ns_', num2str(dims.Ns)];
    case 4
        dims.Nn = 3;
        dims.Np = 4;        
        model = 'var'; 
        dims.ind_n = 1;
        dims.ind_h = 1; 
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Np_', num2str(dims.Np)];
    case 5
        dims.Nn = 20;
        dims.Np = 4;
        dims.ind_n = 1:2;
        dims.ind_h = 1; 
        model = 'var'; 
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Np_', num2str(dims.Np)];
   case 6
        dims.Nn = 100;
        dims.Np = 4;
        dims.ind_n = 1:2;
        dims.ind_h = 1; 
        model = 'var'; 
        dims_str = ['Nt_', num2str(dims.Nt), ...
                   '_Nh_', num2str(dims.Nh), ...
                   '_Nn_', num2str(dims.Nn), ...
                   '_Np_', num2str(dims.Np)];        
end





function [dims, model, dims_str] = get_dims(n_model, Nh, Ncond)
dims.Nt = 100;
dims.Nh = Nh; 

switch(n_model)
    case 1 % small factor model
        dims.Nn = 20;
        dims.Ns = 2;
        dims.Ncond = dims.Nn * Ncond;
        model = 'ssm'; % actually a dfm but called ssm in the functions        
    case 2 % large factor model
        dims.Nn = 100;
        dims.Ns = 2;   
        dims.Ncond = dims.Nn * Ncond;
        model = 'ssm'; % actually a dfm but called ssm in the functions
    case 3 % large N, T factor model
        dims.Nn = 100;
        dims.Ns = 10;  
        dims.Ncond = dims.Nn * Ncond;
        model = 'ssm'; % actually a dfm but called ssm in the functions
    case 4
        dims.Nn = 3;
        dims.Np = 4;        
        model = 'var'; 
        dims.Ncond = 1;
    case 5
        dims.Nn = 20;
        dims.Np = 4;
        dims.Ncond = dims.Nn * Ncond;
        model = 'var'; 
   case 6
        dims.Nn = 100;
        dims.Np = 4;
        dims.Ncond = dims.Nn * Ncond;      
        model = 'var';      
end

if strcmp(model, 'ssm')
    dims_str = ['Nn_', num2str(dims.Nn), ...
           '_Ns_', num2str(dims.Ns), ...
           '_Nh_', num2str(dims.Nh)];
elseif strcmp(model, 'var')
    dims_str = ['Nn_', num2str(dims.Nn), ...
           '_Np_', num2str(dims.Np), ...
           '_Nh_', num2str(dims.Nh)];
end



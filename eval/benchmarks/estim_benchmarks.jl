# This code estimates BayesianAR models as benchmarks for the forecast
# evaluation.
include("./BayesianARs.jl")
using CSV, DelimitedFiles, DataFrames, LinearAlgebra, Distributions, Statistics, .BayesianARs  

###################################################################
# set-up
###################################################################

# order of AR
Np = 2

# prior
m₀ = zeros(Np+1)
Q₀ = diagm(vcat(0.01, collect(1:Np)))
prior_β = MvNormalCanon(Q₀*m₀, Q₀)
prior_σ² = InverseGamma(3, 0.1)

# load list of vintages
list_vintages = readdlm("./../../data/list_vintages.csv", ',', String)

# list of variables
# list_series =  ["p_gdp",         "c_priv",       
#                 "p_c_priv",      "c_gov",         "p_c_gov",      
#                 "gfcf_equip",    "p_gfcf_equip",  "gfcf_constr",  
#                 "p_gfcf_constr", "gfcf_other",    "p_gfcf_other", 
#                 "x",             "p_x",           "m",            
#                 "p_m",           "inv",              
#                 "cpi_core",      "ppi",           "ppi_core",     
#                 "ppi_constr",    "ppi_agri",      "prod_ind",     
#                 "prod_constr",   "ord",           "ord_constr",   
#                 "to",            "to_retail",     "to_constr",    
#                 "h_constr",     
#                 "w"] 

list_series = ["gdp",           "p_gdp",         "c_priv",        "p_c_priv",      "c_gov",         "p_c_gov",      
                "gfcf_equip",    "p_gfcf_equip",  "gfcf_constr",   "p_gfcf_constr", "gfcf_other",    "p_gfcf_other", 
                "x",             "p_x",           "m",             "p_m",           "inv",           "gva_ind",      
                "p_gva_ind",     "gva_constr",    "p_gva_constr",  "gva_tth",       "p_gva_tth",     "gva_freprof",  
                "p_gva_freprof", "cpi",           "cpi_core",      "ppi",           "ppi_core",      "ppi_constr",   
                "ppi_agri",      "prod_ind",      "prod_constr",   "ord",           "ord_constr",    "to",           
                "to_retail",     "to_constr",     "emp",           "h_ind",         "h_constr",      "w"]  

###################################################################
# function to estimate model given vintage and series
###################################################################

function estimate_benchmark(df, v, series)
    ###################################################################
    # prepare data
    ###################################################################

    data_raw = df[:, series]

    y = data_raw[.!isnan.(data_raw)]
    ind_fore = findmax((1:size(data_raw, 1))[.!isnan.(data_raw)])[1] + 1 # in case there are missings at the start of the sample!
    dates_fore = df."date"[ind_fore:end] 

    # comment out this block as I can deal with the missing vintages for h_ind and emp 
    # when I merge with the model forecasts!

    # if length(dates_fore) > 4 || length(dates_fore) < 3
    #     @show series
    #     @show v
    #     error("Expected Nh to lie between 3 and 4")
    # end

    ###################################################################
    # prepare estimation
    ###################################################################

    # forecast horizon and regressors
    Nt = size(y, 1)
    Nh = length(dates_fore)
    X = [ones(Nt-Np, 1) lags(y, Np)]

    # initialize model struct with OLS
    β_ols = (X'*X)\X'*y[Np+1:end] 
    σ²_ols = var(y[Np+1:end]-X*β_ols)
    ar_model = BayesianAR(y, X, Np, β_ols, σ²_ols, prior_β, prior_σ²)

    ###################################################################
    # run Gibss Sampler
    ###################################################################
    β, σ², yᶠ = gibbs_sampler(ar_model;Nh=Nh)

    ###################################################################
    # compile output in DataFrame
    ###################################################################
    Nm = size(yᶠ, 2)
    draws_out = reshape(yᶠ, Nh * Nm, 1)

    dates_out = repeat(dates_fore, Nm)

    #v_out = Vector{String}(undef, Nh*Nm); v_out[:] .= v
    v_out = fill(v, Nh*Nm) # better way to calculate v_out

    #series_out = Vector{String}(undef, Nh*Nm); series_out[:] .= var
    series_out = fill(series, Nh*Nm) # better way to calculate series_out

    #m_out = convert(Vector{Int64}, kron(1:Nm, ones(Nh))) 
    m_out = repeat(1:Nm, inner = Nh) # better way to calculate m_out

    df_tmp = DataFrame()
    df_tmp.vintage = v_out
    df_tmp.quarter = dates_out
    df_tmp.series = series_out
    df_tmp.draw = m_out
    df_tmp.value = vec(draws_out)

    return(df_tmp)
end


###################################################################
# loops over vintages and series
###################################################################

for v in list_vintages
    df_in = DataFrame(CSV.File("./../../data/vintages/vintage" * v * ".csv"))

    df_out = DataFrame()

    for series in list_series
        append!(df_out, estimate_benchmark(df_in, v, series))
    end
    
    CSV.write("./forecasts/benchmark_" * v * ".csv", df_out)
end 


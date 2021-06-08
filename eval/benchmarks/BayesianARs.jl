module BayesianARs
##############################################################
# module to estimate a Bayesian AR(p) model with constant 
# and independen Normal, InverseGamma prior
##############################################################

using Distributions, LinearAlgebra

export BayesianAR, immutBayesianAR # type
export gibbs_sampler # Gibbs Sampler to estimate AR(p)
export sample_β!, sample_σ²!, forecast # main functions 
export f_lin_reg, lags, simulate_data # auxiliary functions
    
# define type
mutable struct BayesianAR
    y::Array{Float64, 1}
    X::Array{Float64, 2}
    Np::Int
    β::Array{Float64, 1}
    σ²::Float64
    prior_β::FullNormalCanon
    prior_σ²::InverseGamma{Float64}
end

struct immutBayesianAR
    y::Array{Float64, 1}
    X::Array{Float64, 2}
    Np::Int
    β::Array{Float64, 1}
    σ²::Float64
    prior_β::FullNormalCanon
    prior_σ²::InverseGamma{Float64}
end

# functions
function sample_β!(ar::BayesianAR)
    Nt = size(ar.X, 1)
    Qₑ = diagm(ones(Nt) * 1 / ar.σ²)
    β_draw =  f_lin_reg(ar.y[ar.Np+1:end], ar.X, ar.prior_β.μ, ar.prior_β.J, Qₑ)
    ar.β = β_draw
end

function sample_β(ar::immutBayesianAR)
    Nt = size(ar.X, 1)
    Qₑ = diagm(ones(Nt) * 1 / ar.σ²)
    β_draw =  f_lin_reg(ar.y[ar.Np+1:end], ar.X, ar.prior_β.μ, ar.prior_β.J, Qₑ)
    return(β_draw)
end


function sample_σ²!(ar::BayesianAR)
    e = ar.y[ar.Np+1:end] - ar.X * ar.β
    ar.σ² = rand(InverseGamma(shape(ar.prior_σ²) + 0.5 * length(e), 
                                    scale(ar.prior_σ²) + 0.5 * dot(e, e)))
end

function sample_σ²(ar::immutBayesianAR)
    e = ar.y[ar.Np+1:end] - ar.X * ar.β
    σ² = rand(InverseGamma(shape(ar.prior_σ²) + 0.5 * length(e), 
                                    scale(ar.prior_σ²) + 0.5 * dot(e, e)))
    return(σ²)
end

function forecast(ar::BayesianAR; Nh)
    tmp = ar.y[end-ar.Np+1:end]
    tmp = vcat(tmp, Vector{Union{Float64,Missing}}(missing, Nh))

    for h in 1:Nh
        m = ar.β[1]
        for p in 1:ar.Np
            m += ar.β[1+p] * tmp[ar.Np+h-p]            
            tmp[ar.Np+h] = randn() * sqrt(ar.σ²) + m
        end
    end
    return(tmp[ar.Np+1:end])
end

function forecast(ar::immutBayesianAR; Nh)
    tmp = ar.y[end-ar.Np+1:end]
    tmp = vcat(tmp, Vector{Union{Float64,Missing}}(missing, Nh))

    for h in 1:Nh
        m = ar.β[1]
        for p in 1:ar.Np
            m += ar.β[1+p] * tmp[ar.Np+h-p]            
            tmp[ar.Np+h] = randn() * sqrt(ar.σ²) + m
        end
    end
    return(tmp[ar.Np+1:end])
end

function gibbs_sampler(ar::BayesianAR;Nh=0, Nburnin=1000, Nreplic=1000, Nthin=1)
    yᶠ = Matrix{Float64}(undef, Nh, Nreplic ÷ Nthin)
    β = Matrix{Float64}(undef, size(ar.X, 2), Nreplic ÷ Nthin)
    σ² = Vector{Float64}(undef, Nreplic ÷ Nthin)    
    for m in 1:(Nreplic+Nburnin)
        sample_β!(ar)
        sample_σ²!(ar)
        if m > Nburnin && m % Nthin == 0
            yᶠ[:, (m - Nburnin) ÷ Nthin] = forecast(ar; Nh)
            β[:, (m - Nburnin) ÷ Nthin] = ar.β
            σ²[(m - Nburnin) ÷ Nthin] = ar.σ²
        end
    end
    return(β, σ², yᶠ)
end

function gibbs_sampler(ar::immutBayesianAR;Nh=0, Nburnin=1000, Nreplic=1000, Nthin=1)
    yᶠ = Matrix{Float64}(undef, Nh, Nreplic ÷ Nthin)
    β = Matrix{Float64}(undef, size(ar.X, 2), Nreplic ÷ Nthin)
    σ² = Vector{Float64}(undef, Nreplic ÷ Nthin)    
    for m in 1:(Nreplic+Nburnin)
        β_draw = sample_β(ar)
        σ²_draw = sample_σ²(ar)
        # given draws construct a new immutBayesianAR instance
        ar = immutBayesianAR(ar.y, ar.X, ar.Np, β_draw, σ²_draw, ar.prior_β, ar.prior_σ²)
        if m > Nburnin && m % Nthin == 0
            yᶠ[:, (m - Nburnin) ÷ Nthin] = forecast(ar; Nh)
            β[:, (m - Nburnin) ÷ Nthin] = ar.β
            σ²[(m - Nburnin) ÷ Nthin] = ar.σ²
        end
    end
    return(β, σ², yᶠ)
end

function f_lin_reg(y::Array{Float64, 1}, 
    X::AbstractArray, 
    m₀::Array{Float64, 1},
    Q₀::AbstractArray{Float64, 2},
    Qₑ::Array{Float64, 2})

    XtQₑ = X'Qₑ
    Q_bet = Q₀ + XtQₑ*X
    cholQ = cholesky(Symmetric(Q_bet))
    m = cholQ.U\(cholQ.L\(Q₀ * m₀ + XtQₑ*y))
    β = cholQ.U \ randn(length(m)) + m
    return(β)
end

function lags(y::AbstractArray{Float64, 1}, Np::Int)
    ylags = zeros(length(y)-Np, Np)
    for p = 1:Np
        ylags[:, p] = y[Np+1-p:end-p] 
    end
    return(ylags)
end

function simulate_data(Nt, Nh)
    β₀ = 0.6
    β₁ = 0.7
    β₂ = -0.2
    β = [β₀, β₁, β₂]
    σ² = 0.7
    Nburn = 10 # this eliminates the impact of the initial conditions
    Np = 2

    y = zeros(Nburn+Nt+Np+Nh)

    for t in (Np+1):(Nt+Np+Nh+Nburn)
        y[t] = β₀ + β₁ * y[t-1] + β₂ * y[t-2] + randn() * sqrt(σ²)
    end

    yᶠ = y[Nburn+Nt+Np+1:Nburn+Nt+Np+Nh]   
    y = y[Nburn+Np+1:Nburn+Nt+Np]

    if length(y) != Nt
        error("Expected length of y to equal Nt!")
    end

    return y, yᶠ, β, σ²
end

end # module
using Pkg
Pkg.activate(".")
using NCDatasets
using CairoMakie
using Interpolations
using LaTeXStrings, MathTeXEngine

include("tools.jl")

z_map4 = cmap(:bukavu, [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000], 1.0)
H_map4 = cmap([:grey28, :lightsteelblue2, :snow], [10, 250, 500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3250, 3500, 3750, 4000], 1.0)
zmap =  (colormap = z_map4, colorrange = (-4000, 2000))
Hmap =  (colormap = H_map4, colorrange = (10, 4000), lowclip=:transparent, highclip=:white)
Hmap_aux = (colormap = H_map4, colorrange = (10, 4000), highclip=:white)

animation_name = "GRL-16KM_PD_flow.mp4"
path2data = "/home/b/b383208/models/yelmox_may25/output2/ismip/exp2/16KM/ctrl6/yelmo2D.nc"
create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, maxsteps=100)

animation_name = "ANT-32KM_PD_flow.mp4"
path2data = "/work/ba1442/sperezmont/yelmox_output/PMYY_MAG_Bipolar/exp02/bipolar_full_ramp01_both_1/south_yelmo2D.nc"
create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, frmrt=1, n=10)






# using CairoMakie

# struct FitzhughNagumo{T}
#     ϵ::T
#     s::T
#     γ::T
#     β::T
# end

# P = FitzhughNagumo(0.1, 0.0, 1.5, 0.8)

# f(x, P::FitzhughNagumo) = Point2f(
#     (x[1]-x[2]-x[1]^3+P.s)/P.ϵ,
#     P.γ*x[1]-x[2] + P.β
# )

# f(x) = f(x, P)
# f([0, 0])
# streamplot(f, -1.5..1.5, -1.5..1.5, colormap = :magma)
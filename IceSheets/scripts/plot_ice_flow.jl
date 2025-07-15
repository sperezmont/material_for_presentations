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

# STOP

# animation_name = "/home/b/b381825/projects/material_for_presentations/IceSheets/flowmap_GRL-16KM_PD.mp4"
# path2data = "/home/b/b383208/models/yelmox_may25/output2/ismip/exp4/16KM/2/ctrl/yelmo2D.nc"
# create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, n=100, maxsteps=500, frmrt=7, thr=2500, density=0.5, grdsz=(48, 48))

# # STOP

# animation_name = "/home/b/b381825/projects/material_for_presentations/IceSheets/flowmap_GRL-16KM_PD_slowvers.mp4"
# path2data = "/home/b/b383208/models/yelmox_may25/output2/ismip/exp4/16KM/2/ctrl/yelmo2D.nc"
# create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, n=100, maxsteps=500, frmrt=4, thr=2500, density=0.5, grdsz=(48, 48), reset_traj=false)

# STOP

animation_name = "/home/b/b381825/projects/material_for_presentations/IceSheets/flowmap_ANT-32KM_PD.mp4"
path2data = "/work/ba1442/sperezmont/yelmox_output/PMYY_MAG_Bipolar/exp02/bipolar_full_ramp01_both_1/south_yelmo2D.nc"
create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, frmrt=10, n=100, maxsteps=500, static_run=true, static_time=1)


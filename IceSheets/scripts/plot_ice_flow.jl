using Pkg
Pkg.activate(".")
using NCDatasets
using CairoMakie
using Interpolations
using LaTeXStrings, MathTeXEngine, DSP

include("tools.jl")

z_map4 = cmap(:bukavu, [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000], 1.0)
H_map4 = cmap([:grey28, :lightsteelblue2, :snow], [10, 250, 500, 750, 1000, 1250, 1500, 1750, 2000, 2250, 2500, 2750, 3000, 3250, 3500, 3750, 4000, 4500], 1.0)
zmap =  (colormap = z_map4, colorrange = (-4000, 2000))
Hmap =  (colormap = H_map4, colorrange = (10, 4500), lowclip=:transparent, highclip=:white)
Hmap_aux = (colormap = H_map4, colorrange = (10, 4000), highclip=:white)

animation_name = "/home/b/b381825/projects/material_for_presentations/IceSheets/flowmap_GRL-16KM_PD.mp4"
path2data = "/home/b/b383208/models/yelmox_may25/output2/ismip/exp4/16KM/2/ctrl/yelmo2D.nc"
create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, n=350, maxsteps=2000, frmrt=5, time_range=0:1:100, thr=2250, density=0.5, grdsz=(48, 48), reset_traj=false, static_run=true, static_time=1)

animation_name = "/home/b/b381825/projects/material_for_presentations/IceSheets/flowmap_ANT-16KM_PD.mp4"
path2data = "/work/ba1442/sperezmont/yelmox_output/jsj_AIS_PD_for_ice_flow_animation/yelmo2D.nc"
create_yelmox_ice_flux_animation(path2data, animation_name, zmap, Hmap, Hmap_aux, frmrt=5, time_range=0:1:500, n=150, maxsteps=2000, thr=3000, static_run=true, static_time=1, density=1.0, grdsz=(50, 50), reset_traj=false)


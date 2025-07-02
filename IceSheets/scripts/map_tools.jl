using Pkg
Pkg.activate(".")
using JLD2, NCDatasets, CairoMakie, LaTeXStrings, Colors

# Levels
levels_bat_GrIS = [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000]
levels_bat_ANT = [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000]
levels_bat_LIS = [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000]

levels_ice_GrIS = 100:250:5500
levels_ice_ANT = 100:250:5500
levels_ice_LIS = 100:250:5500

# Colors
colors_bat = :bukavu
colors_ice = [:snow4, :snow3, :snow2, :snow1, :snow]

# IceSheet Figure struct
Base.@kwdef mutable struct IceSheet
    df_path::String = "/home/sergio/entra/ice_data/Greenland/GRL-16KM/GRL-16KM_TOPO-RTOPO-2.0.1.nc"
    domain::String = "GRL-16KM"
    time_spec::String = "PD"
    grid_spec::String = "TOPO_RTOPO-2.0.1"
    version_spec::String = "v01"
    topo_var::String = "z_bed"
    topo_time_index::Int64 = 1
    ice_var::String = "H_ice"
    ice_time_index::Int64 = 1
end

# Functions
cmap(colors, levels, transp) = cgrad(colors,  round.((levels .- levels[1]) ./ abs(levels[1] - levels[end]), sigdigits=3), categorical=true, alpha=transp)

function create_contour(IS::IceSheet, ice_thr::Real)
    df = NCDataset(IS.df_path)
    set_theme!(theme_latexfonts(), fontsize=15)
    fig = Figure(resolution=(500, 500))
    ax = Axis(fig[1:2, 1],aspect=DataAspect(), backgroundcolor=:transparent)
    hidedecorations!(ax)
    hidespines!(ax)
    contour!(ax, df[IS.ice_var][:, :, IS.ice_time_index], color=:black, levels=[ice_thr])
    rowgap!(fig.layout, 0.0)
    save("./IceSheets/contour_$(IS.time_spec)-$(IS.grid_spec)-$(IS.domain)_$(IS.version_spec).png", fig)

    return
end

function create_map(IS::IceSheet, levels_bat, cmap_bat, levels_ice, cmap_ice)
    df = NCDataset(IS.df_path)
    set_theme!(theme_latexfonts(), fontsize=15)
    fig = Figure(resolution=(500, 500))
    ax = Axis(fig[1:2, 1],aspect=DataAspect())
    hidedecorations!(ax)
    bat = heatmap!(ax, df[IS.topo_var][:, :, IS.topo_time_index], colormap=cmap_bat, colorrange=(levels_bat[1], levels_bat[end]), highclip=:white, lowclip=:grey10)
    ice = heatmap!(ax, df[IS.ice_var][:, :, IS.ice_time_index], colormap=cmap_ice, colorrange=(levels_ice[1], levels_ice[end]), lowclip=:transparent, highclip=:white)

    Colorbar(fig[1, 2], bat, height=Relative(2/3), label="Bathymetry (m)", 
            vertical=true, flipaxis = true)
    Colorbar(fig[2, 2], ice, height=Relative(2/3), label="Ice thickness (m)",
        vertical=true, flipaxis = true)
    rowgap!(fig.layout, 0.0)
    save("./IceSheets/map_$(IS.time_spec)-$(IS.grid_spec)-$(IS.domain)_$(IS.version_spec).pdf", fig)

    return
end

function create_batmap(IS::IceSheet, levels_bat, cmap_bat)
    df = NCDataset(IS.df_path)
    set_theme!(theme_latexfonts(), fontsize=15)
    fig = Figure(resolution=(500, 500))
    ax = Axis(fig[1, 1],aspect=DataAspect())
    hidedecorations!(ax)
    bat = heatmap!(ax, df[IS.topo_var][:, :, IS.topo_time_index], colormap=cmap_bat, colorrange=(levels_bat[1], levels_bat[end]), highclip=:white, lowclip=:grey10)

    Colorbar(fig[1, 2], bat, height=Relative(2/6), label="Bathymetry (m)", 
            vertical=true, flipaxis = true)
    save("./IceSheets/batmap_$(IS.time_spec)-$(IS.grid_spec)-$(IS.domain)_$(IS.version_spec).pdf", fig)

    return
end

function create_transect(IS::IceSheet, x1, y1, x2, y2)
    df = NCDataset(IS.df_path)

    set_theme!(theme_latexfonts(), fontsize=15)

    fig = Figure(resolution=(500, 500))
    ax = Axis(fig[1, 1],aspect=DataAspect())


end

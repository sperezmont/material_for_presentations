include("map_tools.jl")

dftopo = NCDataset("/home/sergio/entra/ice_data/Greenland/GRL-16KM/GRL-16KM_TOPO-RTOPO-2.0.1.nc")
 
# Colormaps
colors = :bukavu
levels_bat = [-4000, -3000, -2000, -1000, -500, -400, -300, -200, -100, -50, -10, 0.0, 10, 50, 100, 200, 300, 400, 500, 750, 1000, 1500, 2000]
cmap_bat = cgrad(colors,  round.((levels_bat .- levels_bat[1]) ./ abs(levels_bat[1] - levels_bat[end]), sigdigits=3), categorical=true)

colors = [:snow4, :snow3, :snow2, :snow1, :snow]
levels_ice = 100:250:3000
cmap_ice = cgrad(colors,  round.((levels_ice .- levels_ice[1]) ./ abs(levels_ice[1] - levels_ice[end]), sigdigits=3), categorical=true)


# Plots
set_theme!(theme_latexfonts(), fontsize=15)
fig = Figure(resolution=(500, 600))
ax = Axis(fig[1, 1],aspect=DataAspect())
hidedecorations!(ax)
bat = heatmap!(ax, dftopo["z_bed"], colormap=cmap_bat, colorrange=(levels_bat[1], levels_bat[end]), highclip=:white, lowclip=:grey10)

Colorbar(fig[1, 2], bat, height=Relative(2/6), label="Bathymetry (m)", 
    #    ticks=([0, 1, 2, 3, 4], convert_strings_to_latex([L"0$\,$", L"10\,m$\,$", L"100\,m$\,$", L"1\,km$\,$", L"10\,km$\,$"])),
        vertical=true, flipaxis = true)
resize_to_layout!(fig)
save("./IceSheets/batmap_GRL-16KM_TOPO_RTOPO-2.0.1_v01.pdf", fig)

# Plots
set_theme!(theme_latexfonts(), fontsize=15)
fig = Figure(resolution=(500, 600))
ax = Axis(fig[1:2, 1],aspect=DataAspect())
hidedecorations!(ax)
bat = heatmap!(ax, dftopo["z_bed"], colormap=cmap_bat, colorrange=(levels_bat[1], levels_bat[end]), highclip=:white, lowclip=:grey10)
ice = contourf!(ax, dftopo["H_ice"], colormap=cmap_ice, levels=levels_ice, extendhigh=:white)

Colorbar(fig[1, 2], bat, height=Relative(2/3), label="Bathymetry (m)", 
    #    ticks=([0, 1, 2, 3, 4], convert_strings_to_latex([L"0$\,$", L"10\,m$\,$", L"100\,m$\,$", L"1\,km$\,$", L"10\,km$\,$"])),
        vertical=true, flipaxis = true)
Colorbar(fig[2, 2], ice, height=Relative(2/3), label="Ice thickness (m)", 
#    ticks=([0, 1, 2, 3, 4], convert_strings_to_latex([L"0$\,$", L"10\,m$\,$", L"100\,m$\,$", L"1\,km$\,$", L"10\,km$\,$"])),
    vertical=true, flipaxis = true)
resize_to_layout!(fig)
save("./IceSheets/map_GRL-16KM_TOPO_RTOPO-2.0.1_v01.pdf", fig)


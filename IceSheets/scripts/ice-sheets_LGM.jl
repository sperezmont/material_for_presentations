using Pkg
Pkg.activate(".")
using JLD2, NCDatasets, CairoMakie, Statistics, LaTeXStrings
include(pwd()*"/scripts/misc/tools.jl")

dfant = NCDataset("/home/sergio/entra/ice_data/Antarctica/ANT-32KM/ANT-32KM_TOPO-ICE-6G_C.nc")
dfnorth = NCDataset("/home/sergio/entra/ice_data/North/NH-32KM/NH-32KM_TOPO-ICE-6G_C.nc")

oceannorth = dfnorth["z"][:, :, 1]
oceannorth[dfnorth["sftlf"][:, :, 1].>10] .= -9999
oceanant = dfant["z"][:, :, 1]
oceanant[dfant["sftlf"][:, :, 1].>10] .= -9999

toponorth = dfnorth["z"][:, :, 1]
toponorth[dfnorth["sftlf"][:, :, 1].<=10] .= -9999
topoant = dfant["z"][:, :, 1]
topoant[dfant["sftlf"][:, :, 1].<=10] .= -9999

icenorth = dfnorth["zs"][:, :, 1]
icenorth[dfnorth["sftgif"][:, :, 1].<=10] .= -9999
iceant = dfant["zs"][:, :, 1]
iceant[dfant["sftgif"][:, :, 1].<=10] .= -9999

oceanlevels = -6600:600:600
oceanmap = cgrad([:midnightblue, :royalblue4, :steelblue, :royalblue, :aliceblue])
topolevels = -5500:500:5500
topomap = :darkterrain
icelevels = 0:500:5500
icemap = cgrad([:snow4, :snow3, :snow2, :snow1, :snow])

fig = Figure(resolution=(1500, 750), fonts=(; regular="Makie"), fontsize=25)
ax = Axis(fig[1, 1], xgridvisible=false, ygridvisible=false)
hidexdecorations!(ax)
hideydecorations!(ax)
hidespines!(ax, :b, :t, :l, :r)
contourf!(ax, dfnorth["xc"][:], dfnorth["yc"][:], oceannorth, colormap=oceanmap, levels=oceanlevels)
contourf!(ax, dfnorth["xc"][:], dfnorth["yc"][:], toponorth, colormap=topomap, levels=topolevels)
contourf!(ax, dfnorth["xc"][:], dfnorth["yc"][:], icenorth, colormap=icemap, levels=icelevels)
contour!(ax, dfnorth["xc"][:], dfnorth["yc"][:], icenorth, colormap=[:grey20], levels=[10])

ax = Axis(fig[1, 2], xgridvisible=false, ygridvisible=false)
hidexdecorations!(ax)
hideydecorations!(ax)
hidespines!(ax, :b, :t, :l, :r)
contourf!(ax, dfant["xc"][:], dfant["yc"][:], oceanant, colormap=oceanmap, levels=oceanlevels)
contourf!(ax, dfant["xc"][:], dfant["yc"][:], topoant, colormap=topomap, levels=topolevels)
contourf!(ax, dfant["xc"][:], dfant["yc"][:], iceant, colormap=icemap, levels=icelevels)
contour!(ax, dfant["xc"][:], dfant["yc"][:], iceant, colormap=[:grey20], levels=[10])

save("figures/ice-sheets_LGM.png", fig)

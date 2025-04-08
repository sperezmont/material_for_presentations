include("map_tools.jl")

## Greenland
gris16kmPDRtopo = IceSheet(df_path = "/home/sergio/entra/ice_data/Greenland/GRL-16KM/GRL-16KM_TOPO-RTOPO-2.0.1.nc",
                           domain = "GRL-16KM",
                           time_spec = "PD",
                           grid_spec = "TOPO_RTOPO-2.0.1",
                           version_spec = "v01",
                           )

create_contour(gris16kmPDRtopo, 10.0)
create_map(gris16kmPDRtopo, levels_bat_GrIS, cmap(colors_bat, levels_bat_GrIS, 1.0), levels_ice_GrIS, cmap(colors_ice, levels_ice_GrIS, 1.0))
create_batmap(gris16kmPDRtopo, levels_bat_GrIS, cmap(colors_bat, levels_bat_GrIS, 1.0))

## Antarctica
ais16kmPDRtopo = IceSheet(df_path = "/home/sergio/entra/ice_data/Antarctica/ANT-16KM/ANT-16KM_TOPO-RTOPO-2.0.1.nc",
                           domain = "ANT-16KM",
                           time_spec = "PD",
                           grid_spec = "TOPO_RTOPO-2.0.1",
                           version_spec = "v01",
                           )

create_contour(ais16kmPDRtopo, 10.0)
create_map(ais16kmPDRtopo, levels_bat_ANT, cmap(colors_bat, levels_bat_ANT, 1.0), levels_ice_ANT, cmap(colors_ice, levels_ice_ANT, 1.0))
create_batmap(ais16kmPDRtopo, levels_bat_ANT, cmap(colors_bat, levels_bat_ANT, 1.0))

## Laurentide
# lis16kmLGMICE6G = IceSheet(df_path = "/home/sergio/entra/ice_data/Laurentide/LIS-16KM/LIS-16KM_TOPO-ICE-6G_C_spmmod.nc",
#                            domain = "LIS-16KM",
#                            time_spec = "LGM",
#                            grid_spec = "TOPO-ICE-6G_C",
#                            version_spec = "v01",
#                            topo_time_index = 1,
#                            ice_time_index = 1
#                            )
# create_map(lis16kmLGMICE6G, levels_bat_LIS, cmap(colors_bat, levels_bat_LIS, 1.0), levels_ice_LIS, cmap(colors_ice, levels_ice_LIS, 1.0))
# create_batmap(lis16kmLGMICE6G, levels_bat_LIS, cmap(colors_bat, levels_bat_LIS, 1.0))
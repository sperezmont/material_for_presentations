include("map_tools.jl")

df = NCDataset("/home/sergio/entra/ice_data/Laurentide/LIS-16KM/LIS-16KM_TOPO-ICE-6G_C.nc")
x, y, time = df["xc"], df["yc"], df["time"]
topo, oro, dz = df["z"][:, :, :], df["zs"][:, :, :], df["dz"][:, :, :]
ice_mask = df["sftgif"][:, :, :]

ice = deepcopy(dz)
ice_end = deepcopy(oro[:, :, end])
ice_end[ice_mask[:, :, end] .<= 0.1] .= 0.0
for t in eachindex(time)    # take only dz with ice land fraction greater than 0
    icet, maskt = ice[:, :, t], ice_mask[:, :, t]
    icet[maskt .<= 0.1] .= 0.0
    ice[:, :, t] = icet .+ ice_end
end

rm("/home/sergio/entra/ice_data/Laurentide/LIS-16KM/LIS-16KM_TOPO-ICE-6G_C_spmmod.nc")
ds = NCDataset("/home/sergio/entra/ice_data/Laurentide/LIS-16KM/LIS-16KM_TOPO-ICE-6G_C_spmmod.nc" ,"c")
defDim(ds,"xc",length(x))
defDim(ds,"yc",length(y))
defDim(ds,"time",length(time))

xc = defVar(ds,"xc",Float32,("xc",))
xc[:] = x[:]
xc.attrib["units"] = "m"
yc = defVar(ds,"yc",Float32,("yc",))
yc[:] = y[:]
yc.attrib["units"] = "m"
time = defVar(ds,"time",Float32,("time",))
time[:] = time[:]
time.attrib["units"] = "yr"

H_ice = defVar(ds,"H_ice",Float32,("xc","yc","time"))
H_ice[:, :, :] = ice
H_ice.attrib["units"] = "m"

z_bed = defVar(ds,"z_bed",Float32,("xc","yc","time"))
z_bed[:, :, :] = topo
z_bed.attrib["units"] = "m"
close(ds)
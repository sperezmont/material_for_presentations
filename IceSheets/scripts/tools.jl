using Pkg
Pkg.activate(".")
using NCDatasets
using CairoMakie
using Interpolations
using LaTeXStrings, MathTeXEngine, DSP, Statistics

cmap(colors, levels, transp) = cgrad(colors,  round.((levels .- levels[1]) ./ abs(levels[1] - levels[end]), sigdigits=3), categorical=true, alpha=transp)

"""
This function calculates the trajectory followed by a particle for
a given initial position `(x0, y0)`, a domain `(x,y)`, a velocity field `(u, v)` and a mask `H` during `times`
"""
function calculate_trajectory(x0::Float32, y0::Float32, x::Array, y::Array, u::Array, v::Array, H::Array, z::Array, times::Array; reset_traj::Bool=true)
    traj, vels = [(x0, y0)], []

    # ice_margin = copy(H)
    # ice_margin[H .< 1.0] .= NaN
    # ice_margin[H > 1.0] .= NaN

    # maxtravel_x, maxtravel_y = abs(x[1] - x[2]), abs(y[1] - y[2]) # assuming regular grid, get resolution

    u_itp = extrapolate(interpolate((x, y, times), u, Gridded(Linear())), 0.0)
    v_itp = extrapolate(interpolate((x, y, times), v, Gridded(Linear())), 0.0)
    H_itp = extrapolate(interpolate((x, y, times), H, Gridded(Linear())), 0.0)
    z_itp = extrapolate(interpolate((x, y, times), z, Gridded(Linear())), 0.0)
    # margin_itp = extrapolate(interpolate((x, y, times), ice_margin, Gridded(Linear())), 0.0)

    xt, yt = x0, y0
    push!(vels, sqrt(u_itp(x0, y0, 0)^2 + v_itp(x0, y0, 0)^2))
    for i in 1:length(times)-1    # r(t+1) = r(t) + v(t)*dt
        # Calculate current time, dt and velocities in (x, y, t)
        t = times[i]
        tp1 = times[i+1] 
        dt = tp1 - t

        # Calculate u(x, y, t) and v(x, y, t)
        Ht = H_itp(xt, yt, t)
        if Ht < 10.0 # Check if there is ice at (x, y, t)
            ut, vt = 0.0, 0.0 
        else
            ut = u_itp(xt, yt, t)
            vt = v_itp(xt, yt, t)
        end

        xtp1 = xt + ut*dt
        ytp1 = yt + vt*dt

        # Calculate new position (xtp1, ytp1, t+1) iteratively
        # -- Check if new position is upstream
        # -- Check if there is ice
        ddt = dt
        iter = 0
        while (z_itp(xtp1, ytp1, tp1) > z_itp(xt, yt, t)) || (H_itp(xtp1, ytp1, tp1) < 1.0)
            if iter > 50
                break
            end

            xtp1 = xt + ut*ddt
            ytp1 = yt + vt*ddt

            ddt = 0.5*ddt
            iter = iter + 1
        end

        # Store point (xtp1, ytp1)
        push!(vels, sqrt(u_itp(xtp1, ytp1, t+1)^2 + v_itp(xtp1, ytp1, t+1)^2))
        push!(traj, (xtp1, ytp1))
        
        if (reset_traj) && (Htp1 < 1.0)    # Reset xt, yt to initial conditions
            xtp1, ytp1 = x0, y0            
        end
        xt, yt = xtp1, ytp1
    end

    return traj, vels

end

"""
Finds the local maxima of the smoothed `field` above a threshold `thr`
"""
function find_local_maxima_above_thr(x, y, field, thr; window=5, smoothing_mat=1/9 .* [1 1 1; 1 1 1; 1 1 1])
    nx, ny = size(field)
    sfield = conv(smoothing_mat, field)
    maximas, indexes = [], []
    for i in window+1:nx-window, j in window+1:ny-window
        if (mean(sfield[i-window:i+window, j-window:j+window]) >= thr)    # check if the mean of the area given by window is above thr 
            for wx in 0:window, wy in 0:window                            # check height all around the point
                if (sfield[i, j] >= sfield[i+wx, j+wy]) &&
                     (sfield[i, j] >= sfield[i-wx, j-wy]) 

                    if ((i, j) ∉ indexes)
                        push!(maximas, (x[i], y[j]))
                        push!(indexes, (i, j))  
                    end 
                end     
            end
        end
    end
    return maximas, indexes
end

# d = NCDataset("/home/b/b383208/models/yelmox_may25/output2/ismip/exp4/16KM/2/ctrl/yelmo2D.nc")
# # d = NCDataset("/work/ba1442/sperezmont/yelmox_output/jsj_AIS_PD_for_ice_flow_animation/yelmo2D.nc")

# x, y, z = d["xc"][:], d["yc"][:], d["z_srf"][:, :, 1]
# mat = 1/9 .* [1 1 1; 1 1 1; 1 1 1]
# z_smooth = conv(mat, z)
# maxi, indexes = find_local_maxima_above_thr(d["xc"][:], d["yc"][:], d["z_srf"][:, :, 1], 2500, window=5)
# fig = Figure()
# ax = Axis(fig[1, 1])
# ax2 = Axis(fig[1, 2])
# heatmap!(ax, x, y, z)
# heatmap!(ax2, x, y, z_smooth)
# scatter!(ax2, maxi, color=:red)
# fig


"""
This function computes the initial position `(x, y)` of `n` particles randomly started in local maximas chosed in `field` above `thr` 
"""
function calculate_initial_positions(n, x, y, field, thr)
    if n == 1
        indexes = [argmax(field)]
    else
        maxima, indexes = find_local_maxima_above_thr(x, y, field, thr)#findall( z -> z>=thr, field)

        # if length(indexes) > n  # chose randomly n values
        #     new_indexes, positions = [], collect(1:length(indexes))
        #     while length(new_indexes) < n
        #         rand_index = rand(positions)

        #         if rand_index ∉ new_indexes
        #             push!(new_indexes, rand_index)
        #         end
        #     end
        #     indexes = indexes[new_indexes]
        # end

    end
    return [(x[indexes[i][1]], y[indexes[i][2]]) for i in eachindex(indexes)]
end

function create_list_of_colors(data, colormap, levels)
    # data = [series, time]
    normalized_levels = levels ./ maximum(levels)

    colormap2 = cgrad(colormap, normalized_levels, categorical=true)
    vector_of_colors = collect(colormap2)

    colors = Array{typeof(vector_of_colors[1])}(undef, size(data))
    for i in eachindex(data[:, 1]), j in eachindex(data[1, :])
        colors[i, j] = vector_of_colors[findmin(abs.(data[i, j] .- levels[2:end]))[2]] # levesl[1] is 0
    end
    return colors, colormap2
end

"""
This function creates `plotname` animation from a YelmoX experiment located in `path2run`
"""
function create_yelmox_ice_flux_animation(path2run::String, plotname::String, bat_cmap_kwargs, ice_cmap_kwargs, ice_cmap_aux_kwargs; frmrt=5, n=20, thr=2500, figsize=(900, 800), fs=22, lw=1, rw=0.45, grdsz=(48, 48), density=1.0, maxsteps=150, stepsize=2, reset_traj=true, static_run=true, static_time=1, time_range=0:1:1000)
    # Load data
    data = NCDataset(path2run)
    x, y = view(data["xc"])[:], view(data["yc"])[:]

    # Load some variables
    if static_run
        time_2D = collect(Float32, time_range)  # kyr
        times2use = static_time
        H_ice = Array{Float32}(undef, length(x), length(y), length(time_2D)) 
        z_bed = Array{Float32}(undef, length(x), length(y), length(time_2D)) 
        ux_s = Array{Float32}(undef, length(x), length(y), length(time_2D)) 
        uy_s = Array{Float32}(undef, length(x), length(y), length(time_2D)) 

        H_ice[:, :, :] .= data["H_ice"][:, :, static_time]
        z_bed[:, :, :] .= data["z_bed"][:, :, static_time]
        ux_s[:, :, :] .= data["ux_s"][:, :, static_time]
        uy_s[:, :, :] .= data["uy_s"][:, :, static_time]
    else
        time_2D = view(data["time"])
        times2use = range(1, stop=Int(length(time_2D)), step=1)
        H_ice = view(data["H_ice"])
        z_bed = view(data["z_bed"])
        ux_s = view(data["ux_s"])
        uy_s = view(data["uy_s"])
    end

    # Define some local variables
    n_2D = length(time_2D)
    z_srf = H_ice .+ z_bed

    # Calculate r(x,y,t) of n particles
    # z_srf_mod = copy(z_srf[:, :, static_time])
    # z_srf_mod[H_ice[:, :, static_time] .<= 1.0] .= -Inf
    rxy = calculate_initial_positions(n, x, y, z_srf[:, :, static_time], thr)
    particle_tracks = Array{Tuple{Float32, Float32}}(undef, length(rxy), length(time_2D)) 
    particle_velocities = Array{Float32}(undef, length(rxy), length(time_2D)) 
    for i in eachindex(rxy)
        particle_tracks[i, :], particle_velocities[i, :] = calculate_trajectory(rxy[i][1], rxy[i][2], x, y, ux_s[:,:,:], uy_s[:, :, :], H_ice[:, :, :], z_srf[:, :, :], time_2D[:], reset_traj=reset_traj)
    end

    velocity_colors, velocity_cmap = create_list_of_colors(Makie.pseudolog10.(particle_velocities), :thermal, range(0, stop=Makie.pseudolog10(1500), length=11))

    # Define the observables to let Julia recognize the time dimension
    if static_run
        k = Observable(static_time)
    else
        k = Observable(1)   # time index
    end

    H_ice_obs = @lift(H_ice[:, :, $k])
    z_bed_obs = @lift(z_bed[:, :, $k])
    z_srf_obs = @lift(z_srf[:, :, $k])
    t_obs = @lift("t = $(round(time_2D[$k])) kyr")
    particle_track_obs = @lift(particle_tracks[:, $k])
    particle_velocities_obs = @lift(particle_velocities[:, $k])
    velocity_colors_obs = @lift(velocity_colors[:, $k])


    ux_itp = linear_interpolation((x, y, time_2D[:]), ux_s[:, :, :])    # velocity field interpolators
    uy_itp = linear_interpolation((x, y, time_2D[:]), uy_s[:, :, :])

    f(xy, t::Float32) = Point2f(Makie.pseudolog10(ux_itp(xy[1], xy[2], t)), Makie.pseudolog10(uy_itp(xy[1], xy[2], t)))   # function to plot the streamlines
    sf = Observable(Base.Fix2(f, 0.0f0))

    # Set up animation
    set_theme!(theme_latexfonts())
    fig = Figure(size=figsize, fontsize=fs)

    ax = Axis(fig[1, 1], aspect=DataAspect(), title=t_obs)
    xlims!(ax, (x[1], x[end]))
    ylims!(ax, (y[1], y[end]))
    hidedecorations!(ax)

    z_hm = heatmap!(ax, x, y, z_bed_obs; bat_cmap_kwargs...)
    heatmap!(ax, x, y, H_ice_obs; ice_cmap_kwargs...)
    H_hm = heatmap!(ax, x, y, H_ice[:, :, 1] .* NaN; ice_cmap_aux_kwargs...)
    contour!(ax, x, y, z_srf_obs, color=:grey30, levels=0:500:4000, linestyle=:dashdot)
    strm = streamplot!(ax, sf, x[1]..x[end], y[1]..y[end], gridsize=grdsz, linewidth=lw, arrow_size=0.0, maxsteps=maxsteps, stepsize=stepsize, density=density, colormap=velocity_cmap, lowclip=:transparent, highclip=velocity_cmap[end])
    
    scatter!(ax, particle_track_obs, color=velocity_colors_obs) #, color=range(0, stop=1000, length=length(rxy)), colormap=uxy_s_map4)

    Colorbar(fig[1, 2], z_hm, vertical = true, flipaxis = true, height = Relative(rw),
        valign = :top, label = "Bed elevation (m)")
    Colorbar(fig[1, 2], H_hm, vertical = true, flipaxis = true, height = Relative(rw),
        valign = :bottom, label = "Ice thickness (m)")

    ticks = [0, 1, 10, 100, 1000]
    Colorbar(fig[1, 3], strm, vertical = true, flipaxis = true, height = Relative(rw),
        valign = :bottom, label = "Surface velocity (m/yr)", ticks = (Makie.pseudolog10.(ticks), string.(ticks)))

    colgap!(fig.layout, 1, 10.0)
    colgap!(fig.layout, 2, 0.0)
    
    save("$(plotname).png", fig)

    # Create animation
    record(fig, "$(plotname)", 1:n_2D, framerate = frmrt) do i
        k[] = i
        sf[] = Base.Fix2(f, time_2D[i])

        # for p in eachindex(particle_track_obs.val[:])
        #     scatter!(ax, particle_track_obs.val[p], color=velocity_colors_obs.val[p]) #, color=range(0, stop=1000, length=length(rxy)), colormap=uxy_s_map4)
        # end

    end
    rm("$(plotname).png")
    return nothing

end
using Pkg
Pkg.activate(".")
using NCDatasets
using CairoMakie
using Interpolations
using LaTeXStrings, MathTeXEngine

cmap(colors, levels, transp) = cgrad(colors,  round.((levels .- levels[1]) ./ abs(levels[1] - levels[end]), sigdigits=3), categorical=true, alpha=transp)

"""
This function calculates the trajectory followed by a particle for
a given initial position `(x0, y0)`, a domain `(x,y)`, a velocity field `(u, v)` and a mask `H` during `times`
"""
function calculate_trajectory(x0::Float32, y0::Float32, x::Array, y::Array, u::Array, v::Array, H::Array, times::Array)
    traj = [(x0, y0)]

    margins_mask = copy(H)
    margins_mask[H .< 10.0] .= 0.0
    margins_mask[H .> 10.0] .= 0.0
    margins_mask[H .== 10.0] .= 1.0

    u_itp = extrapolate(interpolate((x, y, times), u, Gridded(Linear())), 0.0)
    v_itp = extrapolate(interpolate((x, y, times), v, Gridded(Linear())), 0.0)
    H_itp = extrapolate(interpolate((x, y, times), H, Gridded(Linear())), 0.0)

    xt, yt = x0, y0
    for i in 1:length(times)-1    # r(t+1) = r(t) + v(t)*dt
        # Calculate current time, dt and velocities in (x, y, t)
        t = times[i]
        tp1 = times[i+1] 
        dt = tp1 - t

        # Check if there is ice at (x, y, t) and calculate u(x, y, t) and v(x, y, t)
        Ht = H_itp(xt, yt, t)
        if Ht < 10.0
            ut, vt = 0.0, 0.0
        else
            ut = u_itp(xt, yt, t)
            vt = v_itp(xt, yt, t)
        end

        # Calculate new position (xtp1, ytp1, t+1)
        xtp1 = xt + ut*dt
        ytp1 = yt + vt*dt

        # Check if there is ice
        Htp1 = H_itp(xtp1, ytp1, tp1)
        if Htp1 < 10.0    # the particle does not move
            xtp1, ytp1 = xt, yt            
        end

        # Store point (xtp1, ytp1)
        push!(traj, (xtp1, ytp1))
        
        # if Htp1 < 10.0    # Reset xt, yt to initial conditions
        #     xtp1, ytp1 = x0, y0            
        # end
        xt, yt = xtp1, ytp1
    end

    return traj

end

"""
This function computes the initial position `(x, y)` of `n` particles in `field` above `thr` 
"""
function calculate_initial_positions(n, x, y, field, thr)
    if n == 1
        indexes = [argmax(field)]
    else
        indexes = findall( x -> x>=thr, field)
        indexes = indexes[Int.(floor.(range(1, stop=length(indexes), length=n)))]
    end
    return [(x[indexes[i][1]], y[indexes[i][2]]) for i in eachindex(indexes)]
end

"""
This function creates `plotname` animation from a YelmoX experiment located in `path2run`
"""
function create_yelmox_ice_flux_animation(path2run::String, plotname::String, bat_cmap_kwargs, ice_cmap_kwargs, ice_cmap_aux_kwargs; frmrt=5, n=20, thr=2500, figsize=(900, 800), fs=22, lw=1, rw=0.45, grdsz=(48, 48), maxsteps=150, stepsize=2)
    # Load data
    data = NCDataset(path2data)

    # Load some variables
    time_2D = view(data["time"])
    x, y = view(data["xc"])[:], view(data["yc"])[:]
    H_ice = view(data["H_ice"])
    z_bed = view(data["z_bed"])
    ux_s = view(data["ux_s"])
    uy_s = view(data["uy_s"])

    # Define some local variables
    n_2D = length(time_2D)
    z_srf = H_ice .+ z_bed

    uxy_s_map4 = cgrad([:white, :darkred], range(0, stop = 1, length = 11), categorical = true)
    lin_umap = (colormap=uxy_s_map4, colorrange=(1f-8, 1000), colorscale=Makie.pseudolog10,
                lowclip=:transparent, highclip=uxy_s_map4[end])

    # Calculate r(x,y,t) of n particles
    rxy = calculate_initial_positions(n, x, y, H_ice[:, :, 1], thr)
    particle_tracks = Array{Tuple{Float32, Float32}}(undef, length(rxy), length(time_2D)) 
    for i in eachindex(rxy)
        particle_tracks[i, :] = calculate_trajectory(rxy[i][1], rxy[i][2], x, y, ux_s[:,:,:], uy_s[:, :, :], H_ice[:, :, :], time_2D[:])
    end

    # Define the observables to let Julia recognize the time dimension
    k = Observable(1)   # time index

    H_ice_obs = @lift(H_ice[:, :, $k])
    z_bed_obs = @lift(z_bed[:, :, $k])
    z_srf_obs = @lift(z_srf[:, :, $k])
    t_obs = @lift("t = $(round(time_2D[$k])) yr")
    particle_track_obs = @lift(particle_tracks[:, $k])

    ux_itp = linear_interpolation((x, y, time_2D[:]), ux_s[:, :, :])    # velocity field interpolators
    uy_itp = linear_interpolation((x, y, time_2D[:]), uy_s[:, :, :])

    f(xy, t::Float32) = Point2f(ux_itp(xy[1], xy[2], t), uy_itp(xy[1], xy[2], t))   # function to plot the streamlines
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
    strm = streamplot!(ax, sf, x[1]..x[end], y[1]..y[end], gridsize=grdsz, linewidth=lw, arrow_size=0.0, maxsteps=maxsteps, stepsize=stepsize, colormap=[:black])
    scatter!(ax, particle_track_obs, color=:black)

    Colorbar(fig[1, 2], z_hm, vertical = true, flipaxis = true, height = Relative(rw),
        valign = :top, label = "Bed elevation (m)")
    Colorbar(fig[1, 2], H_hm, vertical = true, flipaxis = true, height = Relative(rw),
        valign = :bottom, label = "Ice thickness (m)")

    # Colorbar(fig[1, 3], strm, vertical = true, flipaxis = true, height = Relative(rw),
    #     valign = :bottom, label = "Surface velocity (m/yr)", ticks = 0:200:1000)

    colgap!(fig.layout, 0.0)
    
    save("$(plotname).png", fig)

    # Create animation
    record(fig, "$(plotname)", 1:n_2D, framerate = frmrt) do i
        k[] = i
        sf[] = Base.Fix2(f, time_2D[i])
    end
    rm("$(plotname).png")
    return nothing

end
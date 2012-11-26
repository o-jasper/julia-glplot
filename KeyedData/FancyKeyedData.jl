#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Fancy 'version', with a bunch of stuff plotted consistently.
type FancyKeyedData{K}
    kd::KeyedData{K} #Wrt the data it is just a wrapper of KeyedData.
    
    plot_vars::Array{(K,K),1} #Lines to plot.
    plot_size::Float32 
    ticks_size::(Float32,Float32) #X and y comoving ticks.
    
    bar_vars::Array{(K,K),1} #Intensity bars to plot.
    bar_size::Float32
    
    inc_hist_vars::Array{K,1} #Histograms (some)incoming data.(all into one)
    inc_hist::HistogramLog{ExpandingArray{Float64}} #TODO put it in the sets.
    inc_hist_size::Float32
    
    viewrange_typ_time::Float32
    
    #TODO 
    # * incoming data-cross-other data.
    # * average-over-different lengths of time.
    # * delta-eater & shower
    # * frequency plot
end

prep_vars{K}(x::Array{(K,K)})      = x
prep_vars{K}(single::(K,K))        = [single]
prep_vars{K}(list::(K,Array{K,1})) = map(x->(list[1],x), list[2])

function FancyKeyedData{K}(kd::KeyedData{K}, opts::Options) #TODO make macro for occasion.
    @defaults opts plot_vars = Array((K,K),0) plot_size = 0.9
    @defaults opts ticks_dx = 0.1 
    @defaults opts ticks_dy = ticks_dx
    @defaults opts ticks_size = (ticks_dx,ticks_dy)
    @defaults opts bar_vars = plot_vars bar_size = 0.1
#    @defaults opts inc_hist_vars = nothing
    @defaults opts inc_hist_d=0.1 inc_hist_low=1e-2
    if true # is(inc_hist_vars, nothing)
        inc_hist_vars,pv,bv = (Array(K,0), Array((K,K),0), Array((K,K),0))
        for el in prep_vars(plot_vars)
            push(inc_hist_vars, el[1])
            push(pv, el)
        end
        for el in prep_vars(bar_vars)
            push(bv,el)
        end
    end
    @defaults opts inc_hist =  HistogramLog(inc_hist_low,inc_hist_d) inc_hist_size = 0.1
    @defaults opts viewrange_typ_time= 10.0
    return FancyKeyedData(kd,
                          pv, float32(plot_size), 
                          (float32(ticks_size[1]),float32(ticks_size[2])),
                          bv, float32(bar_size),
                          inc_hist_vars, inc_hist, float32(inc_hist_size),
                          float32(viewrange_typ_time))
end

FancyKeyedData(K, opts::Options) = FancyKeyedData(KeyedData(K), opts)
FancyKeyedData(x) = FancyKeyedData(x, @options)

#Change the main plot of the thing
function main_plot{K}(fkd::FancyKeyedData{K}, vars::Array{(K,K),1}, opts::Options)
    @defaults opts bar_follows_p=true hist_follows_p=true hist_reset_p=true
    vars = prep_vars(vars)
    fkd.plot_vars = vars
    if bar_follows_p 
        fkd.bar_vars = vars
    end
    if hist_follows_p #TODO see in `type`
        fkd.inc_hist_vars = map(x->x[1], vars)
        if hist_reset_p
            fkd.inc_hist = HistogramLog(fkd.inc_hist.low, fkd.inc_hist.n.d)
        end
    end
    return nothing
end
main_plot{K,T}(fkd::FancyKeyedData{K}, vars::T, opts::Options) = 
    main_plot(fkd, prep_vars(vars), opts)
main_plot{K,T}(fkd::FancyKeyedData{K}, vars::T) = main_plot(fkd, vars, @options)

function gl_plot{K}(kd::FancyKeyedData{K}, opts::Options)
    @defaults opts plot_size = kd.plot_size bar_size = kd.bar_size
    @defaults opts default_view_range_typ_time = kd.viewrange_typ_time
#    @defaults opts view_range_typ_time = kd.viewrange_typ_time
    if plot_size > 0 && !isempty(kd.plot_vars)
        vr = get_data(kd, kd.plot_vars[1], ViewRange, nothing)
        if is(vr,nothing) #None exists yet, make it.
            vr = ViewRange(default_view_range_typ_time)
            set_data(kd, kd.plot_vars[1], vr)
        end
        #TODO range seems shocky...
        timestep_range(vr, plot_range_of(kd.kd.seq, kd.plot_vars))
        range = plot_range_of(vr)
        @with glpushed() begin
            unit_frame_to(0,bar_size, 1,bar_size + plot_size)
            gl_plot(kd.kd, kd.plot_vars, opts)
            @defaults opts ticks_size = kd.ticks_size
            tx,ty = isa(ticks_size, (Number,Number)) ? ticks_size :
                                                      (ticks_size,ticks_size)
            if tx>0 #Ticks, if any.
                @with glpushed() begin
                    unit_frame_to(0,0, tx,1)
                    draw_ticks_y(RangeTicks(range[2],range[4]))
                end
            end
            if ty>0
                unit_frame_to(0,0, 1,ty)
                draw_ticks_x(RangeTicks(range[1],range[3]))
            end
        end
    end
    if bar_size > 0 && !isempty(kd.bar_vars)
        @with glpushed() begin
            unit_frame_to(0,0, 1,bar_size)
            gl_plot_bar_intensity(kd.kd.seq, kd.bar_vars,opts)
        end
    end
end
gl_plot{K}(kd::FancyKeyedData{K}) = gl_plot(kd, @options)

#Incorporate on.
incorporate{K}(fkd::FancyKeyedData{K}, stuff...) = incorporate(fkd.kd, stuff...)
get_data{K}(fkd::FancyKeyedData{K}, stuff...) = get_data(fkd.kd, stuff...)
set_data{K}(fkd::FancyKeyedData{K}, stuff...) = set_data(fkd.kd, stuff...)

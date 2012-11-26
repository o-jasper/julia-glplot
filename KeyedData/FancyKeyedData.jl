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
    inc_hist::HistogramLog{ExpandingArray{Int64}} 
    inc_hist_size::Float32
    
    #TODO 
    # * incoming data-cross-other data.
    # * average-over-different lengths of time.
    # * delta-eater & shower
    # * frequency plot
end

function FancyKeyedData{K}(kd::KeyedData{K}, opts::Options) #TODO make macro for occasion.
    @defaults opts plot_vars = Array((K,K),0) plot_size = 0.9
    @defaults opts ticks_dx = 0.1, ticks_dy = ticks_dy 
    @defaults opts ticks_size = (ticks_dx,ticks_dy)
    @defaults opts bar_vars = plot_vars bar_size = 0.1
    @defaults opts inc_hist_vars = Array(K,0) inc_hist_d=0.1 inc_hist_low = 1e-2
    @defaults opts inc_hist =  HistogramLog(inc_hist_low,inc_hist_d) inc_hist_size = 0.1
    return FancyKeyedData(kd,
                          plot_vars, plot_size,ticks_size,
                          bar_vars, bar_size,
                          inc_hist_vars, inc_hist, inc_hist_size)
end

FancyKeyedData(K, opts::Options) = FancyKeyedData(KeyedData(K), opts)
FancyKeyedData(x) = FancyKeyedData(x, @options)

#Change the main plot of the thing
function main_plot{K}(fkd::FancyKeyedData{K}, vars::Array{(T,T),1}, opts::Options)
    @defaults opts bar_follows_p=true, hist_follows_p=true hist_reset_p=true
    fkd.plot_vars = vars
    if bar_follows_p 
        fkd.bar_vars = var_vars = vars
    end
    if hist_follows
        fkd.inc_hist_vars = map(x->x[1], vars)
        if hist_reset_p
            fkd.inc_hist = HistogramLog(fkd.inc_hist.low, fkd.inc_hist.n.d)
        end
    end
    return nothing
end

#TODO
function gl_plot{K}(kd::FancyKeyedData{K}, opts::Options)
    @defaults opts plot_size = kd.plot_size bar_size = kd.bar_size
    #also ticks_size
    if plot_size > 0
        timestep_range(vr, plot_range_of(seq, (:t,[:x,:y])))
        range = plot_range_of(vr)
        @with glpushed() begin
            unit_frame_to(0,bar_size, bar_size + plot_size,1)
            gl_plot(kd.kd, kd.plot_vars, opts)
            @defaults opts ticks_size = kd.ticks_size
            tx,ty = isa(ticks_size, (Number,Number)) ? ticks_size : (ticks_size,ticks_size)
            if tx>0 #Ticks, if any.
                @with glpushed() begin
                    unit_frame_to(0,0, tx,1)
                    draw_ticks_x(range[1],range[3])
                end
            end
            if ty>0
                unit_frame_to(0,0, 1,ty)
                draw_ticks_y(range[2],range[4])
            end
        end
    end
    if bar_size > 0
        @with glpushed() begin
            unit_frame_to(0,0, bar_size,1)
            gl_plot_bar_intensity(kd.kd, kd.bar_vars,opts)
        end
    end
end
gl_plot{K}(kd::FancyKeyedData{K}) = gl_plot(kd, ij, @options)

#Incorporate on.
incorporate{K}(fkd::FancyKeyedData{K}, stuff...) = incorporate(fkd.kd, stuff...)
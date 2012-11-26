#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#View range of a data point pair.(goes into info of Single)
type ViewRange
    t::Float64
    typ_time::Float64
    range::(Float64,Float64,Float64,Float64)
end
ViewRange(typ_time::Number) = ViewRange(typemin(Float64),float64(typ_time),
                                        (float64(-1),float64(-1), float64(1),float64(1)))
ViewRange() = ViewRange(0.1)

function timestep_range(vr::ViewRange, aim_range, at_t,typ_time)
    if typ_time==0 || vr.t==typemin(Float64) #Go straight there.
        vr.range = aim_range
    else
        afx,afy,atx,aty = aim_range
        fx,fy,tx,ty = vr.range
        t= vr.t
        f = exp((at_t-t)/typ_time)-1 #Weighed average.
        o,n = 1/(1+f), f/(1+f)
        vr.range = (n*afx + o*fx, n*afy + o*fy, 
                    n*atx + o*tx, n*aty + o*ty)
    end
    vr.t = at_t
    return vr.range
end
timestep_range(vr::ViewRange, aim_range,at_t) = 
    timestep_range(vr,aim_range,at_t, vr.typ_time)
timestep_range(vr::ViewRange, aim_range) = 
    timestep_range(vr,aim_range, time())

#What the viewrane is for, making plot ranges.
function plot_range_of(vr::ViewRange, opts::Options)
    @defaults opts set_range = false aim_range = nothing
    if set_range #Set the range.
        vr.range = aim_range
    elseif !is(aim_range, nothing)
        @defaults opts at_t = time() typ_time = vr.typ_time
        timestep_range(vr, aim_range, at_t, typ_time)
    end
    @defaults opts min_range = nothing
    if !is(min_range,nothing)
        vr.range = range_union(vr.range, min_range)
    end
    return vr.range
    
end
plot_range_of(vr::ViewRange) = plot_range_of(vr, @options)

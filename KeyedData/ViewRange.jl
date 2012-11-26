#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Extends the ViewRange to suit the KeyedData.(can be `set_single_data`)

incorporate(vr::ViewRange, whatever...) = nothing #Doesnt incorporate stuff.

#Ensures a ViewRange exists as data object.
function ensure_viewrange(kd::KeyedData{K}, ij::(K,K), opts::Options)
    vr = get_pair_data(kd, ij,ViewRange, nothing)
    if vr==nothing 
        @defaults opts default_typ_time = 0.1
        @defaults opts typ_time = default_typ_time
        vr = ViewRange(typ_time)
        set_pair_data(kd, ij, vr)
    end
    return vr
end
#Make keyed data give the viewrange for it.
function plot_range_of{K}(kd::KeyedData{K}, ij::(K,K), opts::Options)
    @defaults opts aim_range = plot_range_of(ContinuousSeqIter(kd.seq, ij), opts)
    @defaults opts flow_p = false 
    @defaults opts vr = (flow_p ? ensure_viewrange(kd,ij,opts) : nothing)
    assert( is(flow_range,nothing) == flow_range_p )
    return  flow_range_p ? plot_range_of(vr,opts) : aim_range
end

#Combine ranges of bunch of things, for i.e. plotting on the same scales.
function plot_range_of{K}(kd::KeyedData{K}, ij::Vector{(K,K)}, opts::Options)
    @defaults opts flow_range_p = true vr = nothing
    assert( is(flow_range,nothing) == flow_range_p )
    if isa(vr,(K,K)) #base the View range on a pair..
        @set_options opts vr = ensure_viewrange(kd, vr, opts)
    end
    return plot_range_of(kd.seq, ij, opts)
end
#Bunch of things in same range, no repeating the x axis.
plot_range_of{K}(kd::KeyedData{K}, ij::(K,Vector{K}), opts::Options) =
    plot_range_of(kd, map((j)->(ij[1],j), ij[2]), opts)

plot_range_of{K,IJ}(cp::KeyedData{K}, ij::IJ) =
    plot_range_of(kd, ij, @options)


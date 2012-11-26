#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#TODO arbitrary math in iterating? Somewhere else?

type ContinuousSeq{K}
    #Sequence of values for each.
    seq::Array{(K,Float64),1}
    #TODO probably a 'list' with the values would do..
    duration::Dict{K,Float64}
    drop_excess_p::Bool
end

ContinuousSeq(K) = 
    ContinuousSeq(Array((K,Float64),0), Dict{K,Float64}(), true)

type ContinuousSeqIter{K}
    #To iterate two entries.
    seq::Vector{(K,Float64)}
    i::K
    j::K
end
ContinuousSeqIter{K}(at::ContinuousSeq, ij::(K,K)) =
    ContinuousSeqIter(at.seq, ij[1],ij[2])

function start{K}(at::ContinuousSeqIter{K})
    k = 1
    while k <= length(at.seq) && at.i != at.seq[k][1]
        k+=1
    end
    return int64(k)
end
function next{K}(at::ContinuousSeqIter{K}, k::Int64)
    assert( k>=1 && !isempty(at.seq) )
    ik = k
    while k < length(at.seq) && at.j != at.seq[k][1]
        k+=1
    end
    jk = k
    while k < length(at.seq) && at.i != at.seq[k][1]
        k+=1
    end
    return ((at.seq[ik][2],at.seq[jk][2]), k)
end
done{K}(at::ContinuousSeqIter{K}, k::Int64) =
    isempty(at.seq) || (k >= length(at.seq))

function drop_excess{K}(cp::ContinuousSeq{K}, duration::Dict{K,Float64})
  #Keep popping until before the end of duration.
    for kv in cp.duration
        k, delta_t = kv
        t = -delta_t
        j = length(cp.seq)
        while j>0 #Figure out last value
            if cp.seq[j][1]==k
                t+=cp.seq[j][2]
                break
            end
            j-=1
        end
        for j = 1:length(cp.seq) #Figure what to take off.
            if cp.seq[j][1]==k && t < cp.seq[j][2] #a time before.
                cp.seq = cp.seq[j:] #Take it off.
                break
            end
        end
    end
end
drop_excess{K}(cp::ContinuousSeq{K}) = drop_excess(cp, cp.duration)
#Add items.
function incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number, opts::Options)
    push(cp.seq, (k, float64(x)))
    @defaults opts drop_excess_p = cp.drop_excess_p
    if drop_excess_p #Drop what we dont want anymore.
        return drop_excess(cp)
    end
end
incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number) =
    incorporate(cp, k,x, @options)


#Histogram of everything item of key.
function hist_now{K,H}(cp::ContinuousSeq{K}, i::K, h::H)
    for el in cp.seq
        if el[1]==i
            incorporate(h, el[2])
        end
    end
    return h
end
#Histogram every pair of those keys.
function hist_now{K,H}(cp::ContinuousSeq{K}, ij::(K,K), h::H)
    got_x = false
    x = float64(-1)
    i,j = ij
    for el in cp.seq
        if el[1]==i
            got_x = true
            x = el[2]
        end
        if el[2]==j && got_x
            incorporate(h, x,el[2])
        end
    end
    return h
end

function plot_range_of{K}(cp::ContinuousSeq{K}, ij::(K,K), opts::Options)
    @defaults opts at_t = time()
    @defaults opts aim_range = plot_range_of(ContinuousSeqIter(cp, ij), opts)
    @defaults opts flow_p = false vr = nothing
    assert( is(vr,nothing) == !flow_p )
    return !is(vr,nothing) ? plot_range_of(vr, opts) : aim_range
end

function plot_range_of{K}(cp::ContinuousSeq{K}, ij::Vector{(K,K)},
                          opts::Options)
    function aim_r() #Restricts the aim range.
        @defaults opts max_range = maximum_range
        @defaults opts min_range = minimum_range
        range = min_range
        for el in ij #Determines how much to enlargen the minimum range.
            range = plot_range_of(ContinuousSeqIter(cp, el), opts)
         #Works by plot_range_of caring about that option.
            @set_options opts min_range = range
        end
        return intersect_range(max_range, range)
    end
    @defaults opts aim_range = aim_r()
    @defaults opts flow_p = false vr = nothing
    assert( is(vr,nothing) == !flow_p )
    if !is(vr,nothing) #View range has to be specified.
        @defaults opts typ_time = vr.typ_time at_t = time()
        timestep_range(vr, aim_range, at_t, typ_time)
    else
        return aim_range
    end
end

plot_range_of{K}(cp::ContinuousSeq{K}, ij::(K,Vector{K}),
                 opts::Options) =
    plot_range_of(cp, map((j)->(ij[1],j), ij[2]), opts)

plot_range_of{K,IJ}(cp::ContinuousSeq{K}, ij::IJ) = 
    plot_range_of(cp, ij, @options)
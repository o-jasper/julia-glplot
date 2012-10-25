#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
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
    #Last range for each pair of keys.
    typ_time::Float32 #Time it takes for the range to change.
    last_range::Dict{(K,K), (Float64,(Float64,Float64,Float64,Float64))}
    #TODO 'ditching values' range.
    duration::Dict{K, Float64}
end

set_duration{K}(cp::ContinuousSeq{K}, k::K, dur::Number) = #!
    assign(seq.duration, float64(dur),k)

function ContinuousSeq(K, typ_time::Number)
    ContinuousSeq(Array((K,Float64),0), float32(typ_time),
                  Dict{(K,K),(Float64,(Float64,Float64,Float64,Float64))}(),
                  Dict{K,Float64}())
end

ContinuousSeq(K) = ContinuousSeq(K,0.1)

type ContinuousSeqIter{K}
    #To iterate two entries.
    seq::Vector{(K,Float64)}
    i::K
    j::K
end
ContinuousSeqIter{K}(at::ContinuousSeq, ij::(K,K)) =
    ContinuousSeqIter(at.seq, ij[1],ij[2])

start{K}(at::ContinuousSeqIter{K}) = int64(1)
function next{K}(at::ContinuousSeqIter{K}, k::Int64)
    while k <= length(at.seq) && at.i != at.seq[k][1]
        k+=1
    end
    ik = k
    while k <= length(at.seq) && at.j != at.seq[k][1]
        k+=1
    end
    jk = k
    while k <= length(at.seq) && at.i != at.seq[k][1]
        k+=1
    end
    return ((at.seq[ik][2],at.seq[jk][2]), k)
end
done{K}(at::ContinuousSeqIter{K}, k::Int64) = (k >= length(at.seq))

function drop_excess{K}(cp::ContinuousSeq{K})
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
#Add items.
function incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number, opts::Options)
    @defaults opts drop_excess_p=true
    push(cp.seq, (k, float64(x)))
    if drop_excess_p #Drop what we dont want anymore.
        return drop_excess(cp)
    end
end
incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number) =
    incorporate(cp, k,x, @options )

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
function timestep_range{K}(cp::ContinuousSeq{K}, ij::(K,K), aim_range, at_t)
    at = at_t
    got = get(cp.last_range, ij, nothing)
    if got==nothing #No earlier range, start at exact range.
        assign(cp.last_range, (at,aim_range), ij)
        return aim_range
    end
    afx,afy,atx,aty = aim_range
    t, (fx,fy,tx,ty) = got
    f = exp((at-t)/cp.typ_time)-1 #Weighed average.
    o,n = 1/(1+f), f/(1+f)
    result = (n*afx + o*fx, n*afy + o*fy, 
              n*atx + o*tx, n*aty + o*ty)
              assign(cp.last_range, (at, result), ij)
    return result
end

function plot_range_of{K}(cp::ContinuousSeq{K}, ij::(K,K), opts::Options)
    @defaults opts at_t = time()
    @defaults opts aim_range = plot_range_of(ContinuousSeqIter(cp, ij), opts)
    @defaults opts flow_range_p = true
    return flow_range_p ? timestep_range(cp, ij, aim_range, at_t) : aim_range
end

function plot_range_of{K}(cp::ContinuousSeq{K}, ij::Vector{(K,K)},
                          opts::Options)
    function aim_r()
        @defaults opts max_range = maximum_range
        @defaults opts min_range = minimum_range
        range = min_range
        for el in ij
            range = plot_range_of(ContinuousSeqIter(cp, el), opts)
            @set_options opts min_range = range
        end
        return intersect_range(max_range, range)
    end
    @defaults opts at_t = time()
    @defaults opts aim_range = aim_r()
    @defaults opts flow_range_p = true
    return flow_range_p ? timestep_range(cp, ij[1], aim_range, at_t) : 
                          aim_range
end
plot_range_of{K,IJ}(cp::ContinuousSeq{K}, ij::IJ) = 
    plot_range_of(cp, ij, @options)
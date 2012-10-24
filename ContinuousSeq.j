#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type ContinuousSeq{K}
    #Sequence of values for each.
    seq::Vector{(K,Float64)}
    #Last range for each pair of keys.
    typ_time::Float32 #Time it takes for the range to change.
    last_range::Dict{(K,K), (Float64,(Float64,Float64,Float64,Float64))}
    #TODO 'ditching values' range.
end
ContinuousSeq{K}(typ_time::Number) =
    ContinuousSeq(Array((K,Float64),0), float64(typ_time),
                  Dict{(K,K),(Float64,(Float64,Float64,Float64,Float64))}())

type ContinuousSeqIter{K}
    #To iterate two entries.
    seq::Vector{(K,Float64)}
    i::K
    j::K
end
ContinuousSeqIter{K}(at::ContinuousSeq, i::K,j::K) =
    ContinuousSeqIter(at.seq, i,j)

start{K}(at::ContinuousSeqIter{K}) = int64(1)
function next{K}(at::ContinuousSeqIter{K}, at_k::Int64) = 
    ik,jk = (int64(-1),int64(-1))
    k = at_k
    while k <= length(at.seq) && at.i != at.seq[k][1]
    end
    ik = k
    while k <= length(at.seq) && at.i != at.seq[k][1]
    end
    jk = k
    return (at.arr[ik][1],at.arr[jk][2]), k+1
end
done{K}(at::ContinuousSeqIter{K}, k::Int64) = (length(at.seq) >= k)

function drop_excess{K}(cp::ContinuousSeq{K})
  #Keep popping until before the end of duration.
#  ret = Array((Float64,Float64),0) #TODO 
#  if length(cp.seq)> 0
#    last_x = cp.seq[length(cp.seq)][1]
#    while( length(cp.seq)>0 &&
#           cp.seq[1][1] + cp.duration < last_x )
#      push(ret, cp.seq[1])
#      cp.seq = cp.seq[2:]
#    end
#  end
end
#Add items.
function incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number, opt::Options)
    @defaults opts drop_excess_p=true time = time()
    push(cp.seq, (k, float64(x)))
    if drop_excess_p #Drop what we dont want anymore.
        return drop_excess(cp)
    end
end
incorporate{K}(cp::ContinuousSeq{K}, k::K, x::Number) =
    incorporate(cp, k,x, @options)

#Histogram 1d of everything in there now.
function hist_now{H}(cp::ContinuousSeq{K}, i::K, h::H)
    for el in cp.seq
        if el[1]==i
            incorporate(h, el[2])
        end
    end
    return h
end
#Histogram 2d every pair in there right now.
function hist_now{H}(cp::ContinuousSeq{K}, i::K,j::K h::H)
    got_x = false
    x = float64(-1)
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
#Change plot range in smooth fashion. (Hmm want to zero second derivative?)
function plot_range{K}(cp::ContinuousSeq{K}, i::K,j::K, 
                       aim_range::(Float64,Float64,Float64,Float64))
    at = time
    afx,afy,atx,aty = aim_range
    got = get(cp.last_range, (i,j), nothing)
    if got==nothing #No earlier range, start at exact range.
        assign(cp.last_range, (at,aim_range), (i,j))
        return (at, aim_range)
    end
    t, (fx,fy,tx,ty) = got
    f = exp((at-t)/typ_time) #Weighed average.
    o,n = 1/(1+f), f/(1+f)
    result = (n*afx + o*fx, n*afy + o*fy, 
              n*afy + o*fy, n*aty + o*ty)
    assign(cp.last_range, (at, result), (i,j))
    return result
end
plot_range{K}(cp::ContinuousSeq{K}, i::K,j::K, opts::Options) = 
    plot_range(cp, plot_range_of(ContinuousSeqIter(cp, i,j, opts))
plot_range{K}(cp::ContinuousSeq{K}, i::K,j::K) =
    plot_range(cp, i,j, @options)

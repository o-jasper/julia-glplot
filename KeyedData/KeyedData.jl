#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type Single{K}
    last_val::Float64
    trigger_also::Array{K,1}
    incorporate_seq_p::Bool
    data::Dict{CompositeKind,Any}
end
Single(K) = Single(typemin(Float64), Array(K,0), 
                   true,Dict{CompositeKind,Any}())

type KeyedData{K}
    single::Dict{K, Single{K}}
    set::Dict{Array{K,1}, Dict{CompositeKind,Any}}

    seq::ContinuousSeq{K}
end
KeyedData(K) =
    KeyedData(Dict{K,Single{K}}(), Dict{Array{K,1},Dict{CompositeKind,Any}}(), 
              ContinuousSeq(K))

#Get single entry, create if it doesnt exist.
function ensure_single{K}(kd::KeyedData{K}, k::K)
    got = get(kd.single, k,nothing)
    if is(got, nothing) 
        got = Single(K)
        assign(kd.single,got, k)
    end
    return got
end
#Set/add single keyed data.
function set_data{K}(kd::KeyedData{K}, to_key::K, set)
    assign(ensure_single(kd,to_key).data, set,typeof(set))
    return set
end
#Get single keyed data.
function get_data{K}(kd::KeyedData{K}, 
                     get_key::K,get_tp::CompositeKind, otherwise)
    got = get(kd.single, get_key, nothing)
    return (is(got,nothing) ? nothing : get(got.data, get_tp, nothing))
end

get_data{K}(kd::KeyedData{K}, get_key::K,get_tp::CompositeKind) =
    get_data(kd, get_key,get_tp, nothing)
#Get pair entry, create if it doesnt exist.
function ensure_tuple{K}(kd::KeyedData{K}, ij::Array{K,1})
    got = get(kd.set, ij,nothing)
    if is(got, nothing)
        got = Dict{CompositeKind,Any}()
        assign(kd.set, got, ij)
    end
    return got
end

#Also trigger other stuff on single entry.
type SingleTrigger{K}
    what::Any #thing to trigger
    under::Array{K,1} #Under what key it is stored.
end

kd_incorporate{K}(kd::KeyedData{K},k::K, st::SingleTrigger{K}, x,step) =
    incorporate(st.what, x,step)

#Also trigger stuff once each of a list has a new one.
type EachTrigger{K}
    what::Any #thing to trigger
    under::Array{K,1} #Under what key it is stored.
#Which have come along since last time typemin(Float64) is not filled.
    have::Array{Float64,1} 
end
function kd_incorporate{K}(kd::KeyedData{K},k::K, et::EachTrigger{K}, x,step)
    i=1
    while i<=length(et.under) && et.under[i]!=k
        i+=1
    end
    assert(i<=length(et.under), "Error: `EachTrigger object wrongly-pointed`")
    et.have[i] = x
    for val in et.have
        if val==typemin(Float64) #One of them not filled yet.
            return nothing
        end
    end
    incorporate(et.what, et.have, step) #All filled, enter and reset.
    et.have = map(x->typemin(Float64), et.have)
    return nothing
end
#Default nothing else needs adding also.
also_set{K}(ij::Array{K,1}, with) = {} 
#1d histograms count everything in the list.
function also_set{K,I}(ij::Array{K,1}, h::HistogramLog{I}) 
    st = SingleTrigger(h, ij)
    return map(k->(k,st), ij)
end

#Set/add tuple keyed data.
function set_data{K}(kd::KeyedData{K}, ij::Array{K,1}, set)
    assign(ensure_tuple(kd,ij), set, typeof(set))
    #Other things to also trigger incorporates on.
    for kv in also_set(ij,set) #List of stuff also set with the thing.
        k,v = kv
        set_data(kd, k,v)
    end
    return set
end
#Set/add tuple keyed data.
get_data{K}(kd::KeyedData{K}, ij::Array{K,1}, tp::CompositeKind, otherwise) =
    get(ensure_tuple(kd,ij), tp, otherwise)
get_data{K}(kd::KeyedData{K}, ij::Array{K,1}, tp::CompositeKind) = 
    get_data(kd, ij, tp, nothing)

kd_incorporate{K}(kd::KeyedData{K},k::K, v,x,step) = incorporate(v,x,step)

function incorporate{K}(kd::KeyedData{K}, k::K, x,step)
    single = ensure_single(kd,k)
    if single.incorporate_seq_p #Incorporate into sequence.
        incorporate(kd.seq, k,x)
    end
    single.last_val = x
    for tp_v in single.data #Incorporate into all of them.
        tp,v = tp_v #(k==typeof(v))
        kd_incorporate(kd,k,v, x,step)
    end
end
incorporate{K}(kd::KeyedData{K}, x,y) = incorporate(kd, x,y,1)

#PointDuration has a special position, to allow ContinuousSeq to do stuff itself.
type PointDuration #Info on how long it keeps a single point.
    duration::Float64
end
PointDuration(d::Number) = PointDuration(float64(d))

incorporate(pd::PointDuration, whatever...) = nothing

set_data{K}(kd::KeyedData{K}, to_key::K, set::PointDuration) =
    assign(kd.seq.duration, set.duration, to_key)
function get_data{K}(kd::KeyedData{K}, get_key::K,
                            get_tp::Type{PointDuration}, otherwise)
    got = get(kd.seq.duration,get_key, nothing)
    return (is(got, nothing) ? otherwise : PointDuration(got))
end

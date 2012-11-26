#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type PointDuration #Info on how long it keeps a single point.
    duration::Float64
end
PointDuration(d::Number) = PointDuration(float64(d))

incorporate(pd::PointDuration, whatever...) = nothing

type Single{K}
    last_val::Float64
    trigger_also::Array{K,1}
    data::Dict{CompositeKind,Any}
end
Single(K) = Single(typemin(Float64), Array(K,0),{},{}, 
                   PointDuration(typemax(Float64)))

type Pair{K}
    data::Dict{CompositeKind,Any}
end
Pair{K}() = Pair{K}(Dict{CompositeKind,Any}())

type KeyedData{K}
    single::Dict{K, Single{K}}
    pair::Dict{(K,K), Array{Any,1}}

    seq::ContinuousSeq{K}
end
KeyedData(K) =
    KeyedData(Dict{K,Single{K}}(), Dict{(K,K),Array{Any,1}}(),
              Array((K,Float64),0), Dict{K,Float64}())

#Get single entry, create if it doesnt exist.
function ensure_single{K}(kd::KeyedData{K}, k::K)
    got = get(kd.single, k,nothing)
    return (is(got, nothing) ? assign(kd.single, k, Single(K)) : got)
end
#Set/add single keyed data.
set_single_data{K}(kd::KeyedData{K}, to_key::K, set) = #!
    assign(ensure_single(kd,to_key).data, typeof(added), set) 

set_single_data{K}(kd::KeyedData{K}, to_key::K, set::PointDuration) = #!
    assign(kd.seq.duration, to_key, set.duration)
#Get single keyed data.
function get_single_data{K}(kd::KeyedData{K}, 
                            get_key::K,get_tp::CompositeKind, otherwise)
    got = get(kd.single, get_key, nothing)
    return (is(got,nothing) ? nothing : get(got.data, get_tp, nothing))
end
function get_single_data{K}(kd::KeyedData{K}, get_key::K,
                            get_tp::Type{PointDuration}, otherwise)
    got = get(kd.seq.duration,get_key, nothing)
    return (is(got, nothing) ? otherwise : PointDuration(got))
end

get_single_data{K}(kd::KeyedData{K}, get_key::K,get_tp::CompositeKind) =
    get_single_data(kd, get_key,get_tp, nothing)
#Get pair entry, create if it doesnt exist.
function ensure_pair{K}(kd::KeyedData{K}, ij::(K,K))
    got = get(kd.pair, ij,nothing)
    return (is(got, nothing) ? assign(kd.pair, k, Pair{K}()) : got)
end
#Set pair keyed data.
set_pair_data{K}(kd::KeyedData{K}, ij::(K,K), set) = #!
    assign(ensure_pair(kd,ij).data, typeof(added), set)
#Get pair keyed data.
get_pair_data{K}(kd::KeyedData{K}, ij::(K,K), otherwise) =
    get(ensure_pair(kd,ij).data, typeof(added), otherwise)
get_pair_data{K}(kd::KeyedData{K}, ij::(K,K)) = 
    get_pair_data(kd, ij, nothing)

function incorporate{K}(kd::KeyedData{K}, k::K, x,step)
    incorporate(kd, k,x)
    single = ensure_single(kd.single,k)
    single.last_val = x
    for kv in single.data #Incorporate into all of them.
        k,v = kv #(k==typeof(v))
        incorporate(v, x,step)
    end
    for tk in single.trigger_also #Add stuff to whatever is triggered.
        for el in get(kd.pair, (tk,k),{})
            got = get(kd.single, tk, nothing)
            if !is(got, nothing) && got.last_val != typemin(Float64)
                incorporate(el, x,got.last_val, step)
            end
        end
    end
end
incorporate{K}(kd::KeyedData{K}, x,y) = incorporate(kd, x,y,1)

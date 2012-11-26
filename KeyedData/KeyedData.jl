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
    set::Dict{(K...), Dict{CompositeKind,Any}}

    seq::ContinuousSeq{K}
end
KeyedData(K) =
    KeyedData(Dict{K,Single{K}}(), Dict{(K...),Dict{CompositeKind,Any}}(), 
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
function ensure_tuple{K}(kd::KeyedData{K}, ij::(K...))
    got = get(kd.set, ij,nothing)
    if is(got, nothing)
        got = Dict{CompositeKind,Any}()
        assign(kd.set, got, ij)
    end
    return got
end
#Set/add tuple keyed data.
function set_data{K}(kd::KeyedData{K}, ij::(K...), set)
    assign(ensure_tuple(kd,ij), set, typeof(set))
    return set
end
#Set/add tuple keyed data.
get_data{K}(kd::KeyedData{K}, ij::(K...), tp::CompositeKind, otherwise) =
    get(ensure_tuple(kd,ij), tp, otherwise)
get_data{K}(kd::KeyedData{K}, ij::(K...), tp::CompositeKind) = 
    get_data(kd, ij, tp, nothing)

function incorporate{K}(kd::KeyedData{K}, k::K, x,step)
    single = ensure_single(kd,k)
    if single.incorporate_seq_p
        incorporate(kd.seq, k,x)
    end
    single.last_val = x
    for kv in single.data #Incorporate into all of them.
        k,v = kv #(k==typeof(v))
        incorporate(v, x,step)
    end
#TODO    
#    for tk in single.trigger_also #Add stuff to whatever is triggered.
#        got = get(kd.single, tk, nothing)
#        if !is(got,nothing) && got.last_val!=typemin(Float64)
#            set = get(kd.set, (tk,k), nothing)
#            if !is(set, nothing)
#                for el in set
#                    incorporate(el[2], x,got.last_val, step)
#                end
#            end
#        end
#    end
end
incorporate{K}(kd::KeyedData{K}, x,y) = incorporate(kd, x,y,1)

#PointDuration has a special position, to allow ContinuousSeq to do stuff itself.
type PointDuration #Info on how long it keeps a single point.
    duration::Float64
end
PointDuration(d::Number) = PointDuration(float64(d))

incorporate(pd::PointDuration, whatever...) = nothing

set_data{K}(kd::KeyedData{K}, to_key::K, set::PointDuration) = #!
    assign(kd.seq.duration, set.duration, to_key)
function get_data{K}(kd::KeyedData{K}, get_key::K,
                            get_tp::Type{PointDuration}, otherwise)
    got = get(kd.seq.duration,get_key, nothing)
    return (is(got, nothing) ? otherwise : PointDuration(got))
end

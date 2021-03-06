#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

after_i{T}(iterable::T, i::Integer) = iterable[i:]
inform_of_range(x, range) = x

call_it{T}(f::Function, x::T) = f(x)

# Plots a (generalized)function path, or a function y=f(x)
#If you define call_it, you can use other things than functions.
type PlotPath{F}
    fun::F     #Function that is called to get values.
    s::Float64 #Starting position.
    t::Float64 #Ending position.
    d::Float64 #Step.
    
    x::Float64 #Current position. #TODO cant this be omitted?
end

PlotPath{F}(fun::F, s::Number,t::Number,d::Number,x::Number) =
    PlotPath(fun, float64(s),float64(t),float64(d), float64(x))
PlotPath{F}(fun::F, s::Number,t::Number,d::Number) = PlotPath(fun, s,t,d, s-d)
PlotPath{F}(at::PlotPath{F}) = PlotPath(at.fun, at.s,at.t,at.d)

const default_n = 100
function PlotPath{F}(fun::F, opts::Options)
    @defaults opts from = float64(0) to = float64(1) n = default_n
    @defaults opts d = float64((to-from)/n)
    return PlotPath(fun, from,to, d)
end
PlotPath{F}(fun::F) = PlotPath(fun, @options)
PlotPath{F}(fun::F, range::(Number,Number), n::Integer) =
    PlotPath(fun, range[1],range[2], (range[2]-range[1])/n)
PlotPath{F}(fun::F, range::(Number,Number)) = PlotPath(fun, range, default_n)

#Seems broken in Julia:4f5332632b239ea9ba23760e6f41373e6be1a6b5
copy{F}(pp::PlotPath{F}) = PlotPath(pp.fun, pp.s,pp.t,pp.d,pp.x)

function inform_of_range{F}(iter::PlotPath{F}, 
                            range::(Number,Number,Number,Number))
    n = 0
    if iter.s == typemin(Float64) 
        assert( iter.t==typemax(Float64) )
        #Range completely determined from outside.
        d = float64( (range[3]-range[1])/iter.d )
        return PlotPath(iter.fun, float64(range[1]),float64(range[3]),
                        d, float64(range[1]-d))
    end
    iter = copy(iter)
    iter.s = max(iter.s, range[1])
    iter.t = min(iter.t, range[3])
    return iter
end

#Get value of function at any point.
function value_at{F}(iter::PlotPath{F}, x::Number)
    pos = call_it(iter.fun, float64(x))
    return isa(pos, Number) ? (iter.x,pos) : pos
end

start{F}(at::PlotPath{F}) = PlotPath(at)
function next{F}(val::PlotPath{F}, iter::PlotPath{F})
    iter.x = min(iter.x + iter.d, iter.t)
    return (value_at(iter, iter.x),iter)
end
done{F}(q::PlotPath{F}, iter::PlotPath{F}) = (iter.x >= iter.t)

function ref{F}(iter::PlotPath{F}, i::Integer)
    x = iter.s + iter.d*i
    if i<0 || x > iter.t
        throw(BoundsError())
    end
    return value_at(iter, x)
end
ref{F,N<:Number}(iter::PlotPath{F}, r::Range1{N}) =
    PlotPath(iter.fun, float64(min(r)),float64(max(r)), iter.d, iter.x)
#Note: `length` doesn't make sense on the concept, forced onto this.
function after_i{F}(iter::PlotPath{F}, i::Integer) 
    ax = iter.s + iter.d*i
    if i<0 || ax > iter.t
        throw("Incorrect bounds $i $(iter.d) $(iter.t)")
    end
    return PlotPath(iter.fun, ax, iter.t, iter.d, iter.x)
end

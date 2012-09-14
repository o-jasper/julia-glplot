#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Adding stuff so they get plottable.
#TODO uhm... shouldn't they be _iterable_, as Julia defines somewhere?

pos(thing,i::Integer, range::(Number,Number,Number,Number)) = pos(thing,i)
done(thing,i::Integer, range::(Number,Number,Number,Number)) = done(thing,i)

#Plots an array of numbers.
pos(arr::Array{Float64,1},i::Integer) = (i,arr[i])
done(arr::Array{Float64,1},i::Integer) = (i>length(arr))

#Plot array of pairs
pos(arr::Array{(Float64,Float64),1},i::Integer) = arr[i]
done(arr::Array{(Float64,Float64),1},i::Integer) = (i>length(arr))
#And vectors.
pos(arr::Array{Array{Float64,1},1},i::Integer) = (arr[i][1],arr[i][2])
done(arr::Array{Array{Float64,1},1},i::Integer) = (i>length(arr))

##Plots a function path.
type PlotPath 
  fun::Function
  s::Float64
  step::Float64
  n::Int32
end

PlotPath(fun::Function, s::Number,t::Number,n::Integer) =
    PlotPath(fun,float64(s),float64((t-s)/n), int32(n))
PlotPath(fun::Function, s::Number,t::Number) =
    PlotPath(fun, s,t, 100)
PlotPath(fun::Function) = 
    PlotPath(fun, 0,1)

pos(pf::PlotPath, i::Integer) = pf.fun(pf.s + pf.step*i)
done(pf::PlotPath, i::Integer) = (i> pf.n)

# A function is defaultly dealt with as a path.
gl_plot_under(mode::Integer, path_fun::Function, 
              range::(Number,Number,Number,Number), 
              to::Number, rectangular::Bool) =
    gl_plot_under(mode, PlotPath(path_fun), range, to, rectangular)
gl_plot(mode::Integer,path_fun::Function, 
        range::(Number,Number,Number,Number)) =
    gl_plot(mode, PlotPath(path_fun), range)

##Plots and x->(x,f(x)) function.
type PlotFun 
  fun::Function
  n::Int32 #Number of divisions.
end

PlotFun(fun::Function) = PlotFun(fun,int32(100))

function pos(pf::PlotFun, i::Integer, range::(Number,Number,Number,Number))
  x = range[1] + i*(range[3]-range[1])/pf.n
  return (x, pf.fun(x))
end
done(pf::PlotFun, i::Integer) = i>pf.n

##Use a function after something else. TODO won't work...
type PostFun{T} #Function after some other thing.
  fun::Function
  thing::T
end
done{T}(pf::PostFun{T}, i::Integer, range::(Number,Number,Number,Number)) =
    done(pf.thing, i,range)
pos{T}(pf::PostFun{T}, i::Integer, range::(Number,Number,Number,Number)) = 
    pf.fun(pos(pf.thing, i,range))

#TODO well this doesn't work... Each has to specify itself? :/
#gl_plot{T}(pf::PostFun{T}, range::(Number,Number,Number,Number)) = 
#    gl_plot(pf.thing, range)

#Some uses of PostFun for logarithmic plots.
log_x{T}(thing::T)  = 
    PostFun(function(v) return (log10(v[1]), v[2]) end, thing)
log_y{T}(thing::T)  = 
    PostFun(function(v) return (v[1], log10(v[2])) end, thing)
log_xy{T}(thing::T) = 
    PostFun(function(v) return (log10(v[1]), log10(v[2])) end,
            thing)


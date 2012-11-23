#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
const maximum_range = (typemin(Float64),typemin(Float64),
                       typemax(Float64),typemax(Float64))
const minimum_range = (typemax(Float64),typemax(Float64),
                       typemin(Float64),typemin(Float64))

#Combining ranges inclusively.
union_range(a::(Float64,Float64,Float64,Float64),
            b::(Float64,Float64,Float64,Float64)) =
    (min(a[1],b[1]), min(a[2],b[2]),  max(a[3],b[3]), max(a[4],b[4]))

union_range(l::Vector) = 
    length(l)==1 ? l[1] : union_range(l[1],union_range(l[2:]))
union_range(l...) = union_range(l)

#Combining ranges; range where all overlaps.
intersect_range(a::(Float64,Float64,Float64,Float64),
                b::(Float64,Float64,Float64,Float64)) =
    (max(a[1],b[1]), max(a[2],b[2]),  min(a[3],b[3]), min(a[4],b[4]))

intersect_range(l::Vector) = 
    length(l)==1 ? l[1] : union_range(l[1],union_range(l[2:]))
intersect_range(l...) = union_range(l)

#2d plot range of any iterable
function plot_range_of{Iterable}(seq::Iterable, opts::Options)
    @defaults opts min_range = minimum_range
    fx,fy,tx,ty = min_range
    for el in seq
        x,y = el
        fx,fy,tx,ty = (min(fx,x),min(fy,y), max(tx,x),max(ty,y))
    end
    return (fx,fy, tx,ty)
end
plot_range_of{Iterable}(seq::Iterable) = plot_range_of(seq, @options)

#Inclusive 2d plot range.
function plot_inclusive_range_of{Iterable}(seq::Vector{Iterable}, 
                                           opts::Options)
    @defaults opts max_range = maximum_range
    @defaults opts min_range = minimum_range
    range = min_range
    for el in seq
        range = plot_range_of(el, opts)
        @set_options opts min_range = range
    end
    return intersect_range(max_range, range)
end
plot_inclusive_range_of{Iterable}(seq::Vector{Iterable}) =
    plot_inclusive_range_of(seq, @options)

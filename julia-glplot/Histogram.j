#
#  Copyright (C) 14-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Using a field as a histogram. Faster, but might expand in memory badly if
# data range big.(The histogram allows you to provide a range.)
incorporate{IArr}(f::Field{IArr}, x::Number, step::Integer) = #!
    (f[x] += step)

# histogram
type Histogram{IArr}
  f::Float64
  t::Float64
  field::Field{IArr}
end
Histogram{IArr}(f::Number,t::Number, field::Field{IArr}) =
    Histogram(float64(f), float64(t), field)

Histogram(fr::Number,to::Number, n::Integer, I) = #Limited histogram.
    Histogram(fr,to, Field(fr,(to-fr)/n, ExpandingArray(I)))

Histogram(fr::Number,to::Number, n::Integer) = Histogram(fr,to, n, Int64)

#Unlimited histogram, Also unlimited(slightly more efficient) is using 
# Field{IArr} directly.
Histogram(d::Number, I) = 
    Histogram(mintype(Float64),maxtype(Float64), ExpandingArray(I))
Histogram(d::Number) = Histogram(d,Int64)

length{IArr}(h::Histogram{IArr}) = length(h.field)
#size{IArr}(h::Histogram{IArr})   = size(h.field)
max{IArr}(h::Histogram{IArr}) = max(h.field)
min{IArr}(h::Histogram{IArr}) = min(h.field)

plot_range_of{IArr}(h::Histogram{IArr}) = (h.f,0, h.t,max(h))

ref{IArr,N<:Number}(h::Histogram{IArr}, x::N) = h.field[x] #(index of number)
#No assign yet.

incorporate{H}(h::H, x::Number) = incorporate(h, x,1)
incorporate{IArr}(h::Histogram{IArr}, x::Number, step::Integer) = #!
   (h.f <= x <= h.t) ?  h.field[x] += step : nothing #Hell, yeah.

#Iterating it. TODO make continuous iter work on it?
start{IArr}(h::Histogram{IArr}) = start(h.field)
done{IArr,State}(h::Histogram{IArr},s::State) = done(h.field,s)
next{IArr,State}(h::Histogram{IArr},s::State) = next(h.field,s)

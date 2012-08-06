#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

# histogram
type Histogram
  s::Float64
  d::Float64
  hist::Array{Int64,1}
end

Histogram(fr::Number,to::Number, n::Integer) =
    Histogram(float64(fr),float64((to-fr)/n), zero(Array(Int64,n)))

length(h::Histogram) = length(h.hist)

max(h::Histogram) = max(h.hist)
min(h::Histogram) = min(h.hist)

range_of(h::Histogram)      = (h.s,min(h), h.s + h.d*length(h),max(h))
plot_range_of(h::Histogram) = (h.s,0, h.s + h.d*length(h),max(h))

incorporate(h, x::Number) = incorporate(h, x,1)

function incorporate_i(h::Histogram, x::Number, step::Integer)
  i = int((x-h.s)/h.d)+1
  if i>=1 && i<= length(h.hist)
    h.hist[i] += step
    return nothing
  end
  return i
end
function incorporate(h::Histogram, x::Number, step::Integer)
  incorporate_i(h, x,step)
  return nothing
end

#Expanding histogram, it registers everything.(but potentially memory-prohibitive)
# everything below does so too.
type HistogramExpanding
  h::Histogram
end

HistogramExpanding(fr::Number,to::Number, n::Integer) =
    HistogramExpanding(Histogram(fr, (to-fr)/n, n))

HistogramExpanding(s::Number,d::Number) =
    HistogramExpanding(Histogram(float64(s),float64(d), zero(Array(Int64,0))))

length(h::HistogramExpanding) = length(h.h)

max(h::HistogramExpanding) = max(h.h)
min(h::HistogramExpanding) = min(h.h)

range_of(h::HistogramExpanding) = range_of(h.h)
plot_range_of(h::HistogramExpanding) = plot_range_of(h.h)

function incorporate(h::HistogramExpanding, x::Number, step::Integer)
  i = incorporate_i(h.h, x,step)
  if i!=nothing
    w = length(h.h.hist)
    if i>0 
      assert( i> w )
      h.h.hist = reshape(h.h.hist, i)
      assert( h.h.hist[i]==0 )
      h.h.hist[i] = step
    else
      h.h.hist = reshape(h.h.hist, w-i)
      h.h.s -= h.h.d
      circshift(h.h.hist, -i)
      incorporate(h, x,step) #Not h.h, trying again after reshape.
    end
  end
  return nothing
end

#Logarithmic histogram. (The log typically dampens the memory use a lot)
type HistogramLog
  low::Float64
  n::HistogramExpanding
  p::HistogramExpanding
end

HistogramLog(low::Number, e::Number) =
    HistogramLog(float64(low), HistogramExpanding(0,e), HistogramExpanding(0,e))

length(h::HistogramLog) = length(h.n) + length(h.p)

max(h::HistogramLog) = max(h.n,h.p)
min(h::HistogramLog) = min(h.n,h.p)

#range_of(h::HistogramExpanding) = 
#plot_range_of(h::HistogramExpanding) = plot_range_of(h.h)

function incorporate(h::HistogramLog, x::Number, step::Integer)
  if x>0
    incorporate(h.p, log(max(x, h.low)), step)
  else
    incorporate(h.p, log(max(-x, h.low)), step)
  end
end

#Histogram with linear part and expanding logarithmic around.
#(records all)
type HistogramFancy
  lin_area::Histogram
  log::HistogramLog
end

max(h::HistogramFancy) = max(h.lin_area,h.log)
min(h::HistogramFancy) = min(h.lin_area,h.log)

HistogramFancy(fr::Number,to::Number, n::Integer, low::Number,e::Number) =
    HistogramFancy(Histogram(fr,to,n),HistogramLog(low,e))

HistogramFancy(fr::Number,to::Number,n::Integer, low::Number,e::Number) =
    Histogram(fr,to, n, low,e)

function incorporate(h::HistogramFancy, x::Number, step::Integer)
  if incorporate(h.lin_area, x,step)!=nothing #If drops out
    incorporate(h.log, x,step)
  end
end

plot_range_of(h::HistogramFancy) = plot_range_of(h.lin_area)

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

function incorporate(h::Histogram, x::Number, step::Integer)
  i = int((x-h.s)/h.d)+1
  if i>=1 && i<= length(h.hist)
    h.hist[i] += step
  end
end

function gnuplot_write(h::Histogram, to::IOStream)
  len = size(h.hist)
  write(to, "#Histogram
#s $(h.s) d $(h.d) len $len")
  for i = 1:len
    write(to, "\n$(h.hist[i])")
  end
end
gnuplot_write{H}(h::H, to::String) = #!
    @with_open_file stream to "w" gnuplot_write(h, stream)

#A reshape that works. (until the julia one starts working again..)
function working_reshape{T}(arr::Array{T,1}, newlen::Integer)
  assert( length(arr) < newlen )
  ret = Array(T, newlen)
  for i = 1:length(arr)
    ret[i] = arr[i]
  end
  return ret
end

#Expands the array if needed, returns the post-expanded index of the given
# position, and new start.
function index_expand_if_needed{T}(arr::Array{T,1}, s::Float64,d::Float64,
                                   x::Float64, zero::T)
  len = length(arr)
  if len==0 #First entry.
    s = s + d*floor((x-s)/d)
    arr = [copy(zero)]
    return (1,s,arr)
  end
  i = int((x-s)/d)
  if i>len #Need to lengthen the array forward.
    arr = working_reshape(arr, i)
    for k = len:i
      arr[k] = copy(zero)
    end
    return (1,s,arr)
  end
#Need to lengthen the array backward. #TODO instead overshoot for speed.
  if i<1 
    arr = working_reshape(arr, len+1-i)
    s -= (1-i)*d
    for k = len:(len+1-i) #Fill the data.
      arr[k] = copy(zero)
    end
    circshift(arr, 1-i) #Move the data.
    return (1,s,arr)
  end
  assert( 1 <= i <= length(arr) )
  return (i,s,arr)
end

#Expanding histogram, it registers everything.
# (but potentially memory-prohibitive, if arbitrary size allowed)
# HistogramLog expands unlimitedly, which shouldn't be too prohibitive due to
# the logarithm.
type HistogramExpanding
  hist::Array{Int64,1}
  s::Float64
  d::Float64
  max_range::(Float64,Float64)
  function HistogramExpanding(h::Histogram, max_range::(Number,Number))
    fr,to = max_range
    new(h.hist, h.s,h.d, (float64(fr),float64(to)))
  end
end
#TODO awful lot of constructors..
HistogramExpanding(h::Histogram) = 
    HistogramExpanding(h, (typemin(Float64), typemax(Float64)))

HistogramExpanding(fr::Number,to::Number, n::Integer, 
                   max_range::(Number, Number)) =
    HistogramExpanding(Histogram(fr, (to-fr)/n, n), max_range)

HistogramExpanding(s::Number,d::Number, max_range::(Number, Number)) =
    HistogramExpanding(Histogram(float64(s),float64(d), zero(Array(Int64,0))),
                       max_range)

HistogramExpanding(s::Number,d::Number) =
    HistogramExpanding(s,d, (typemin(Float64), typemax(Float64)))

length(h::HistogramExpanding) = length(h.hist)

max(h::HistogramExpanding) = max(h.hist)
min(h::HistogramExpanding) = min(h.hist)

range_of(h::HistogramExpanding) = range_of(h.hist)
plot_range_of(h::HistogramExpanding) = (h.s,0, h.s + h.d*length(h),max(h))

function incorporate(h::HistogramExpanding, x::Number, step::Integer)
  fr,to = h.max_range
  if x<fr || x>to #Outside of range.
    return nothing
  end
  i,s,arr = index_expand_if_needed(h.hist, h.s,h.d, x, int64(0))
  h.hist = arr
  h.s = s
  h.hist[i] += step
  return nothing
end
#TODO option to write it as if the whole range has stuff.
function gnuplot_write(h::HistogramExpanding, to::IOStream)
  min,max = h.max_range
  write("#HistogramExpanding\n#min $min max $max\n")
  gnuplot_write(h.h) #Just passes it on.  
end

#Logarithmic histogram. (The log typically dampens the memory use a lot)
type HistogramLog
  low::Float64
  n::HistogramExpanding
  p::HistogramExpanding
end

HistogramLog(low::Number, d::Number) =
    HistogramLog(float64(low), 
                 HistogramExpanding(0,d), HistogramExpanding(0,d))

length(h::HistogramLog) = length(h.n) + length(h.p)

max(h::HistogramLog) = max(h.n,h.p)
min(h::HistogramLog) = min(h.n,h.p)

#range_of(h::HistogramExpanding) = 
#plot_range_of(h::HistogramExpanding) = plot_range_of(h.h)

function incorporate(h::HistogramLog, x::Number, step::Integer)
  if x>0
    incorporate(h.p, log10(max(x, h.low)), step)
  else
    incorporate(h.p, log10(max(-x, h.low)), step)
  end
end

#Histogram with linear part and expanding logarithmic around.
#(records all)
type HistogramLinArea
  lin_area::Histogram
  log::HistogramLog
end

max(h::HistogramLinArea) = max(h.lin_area,h.log)
min(h::HistogramLinArea) = min(h.lin_area,h.log)

HistogramLinArea(fr::Number,to::Number, n::Integer, low::Number,e::Number) =
    HistogramLinArea(Histogram(fr,to,n),HistogramLog(low,e))

HistogramLinArea(fr::Number,to::Number, n::Integer, e::Number) =
    HistogramLinArea(fr,to, n, (to-fr)/n, e)
HistogramLinArea(fr::Number,to::Number, n::Integer) =
    HistogramLinArea(fr,to, n, 2/n)

function incorporate(h::HistogramLinArea, x::Number, step::Integer)
  if !is(incorporate(h.lin_area, x,step), nothing) #If drops out
    incorporate(h.log, x,step)
  end
end

plot_range_of(h::HistogramLinArea) = plot_range_of(h.lin_area)

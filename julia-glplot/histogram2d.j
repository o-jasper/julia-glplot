#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#TODO completely untested!

type Histogram2d #'plain' 2d histogram.
  sx::Float64 #Start.
  sy::Float64
  dx::Float64 #Step.
  dy::Float64 
  hist::Array{Int64,2}
end

Histogram2d(fx::Number,fy::Number, tx::Number,ty::Number,
                 w::Integer,h::Integer) = 
    Histogram2d(float64(fx),float64(fy), 
                float64((tx-fx)/w),float64((ty-fy)/w),
                zero(Array(Int64, w,h)))

nnz(h::Histogram2d) = nnz(h.hist) #Non zero components.

function range(h::Histogram2d)
  w,h = size(h.hist)
  return (h.sx,h.sy, h.sx+h.dx*w, h.sy+h.dy*w)
end

function incorporate(h::Histogram2d, x::Number,y::Number, step::Integer)
  i = int((x-sx)/h.dx)
  j = int((y-sy)/h.dy)
  w,h = size(h.hist)
  if i>=1 && j>=1 && i<=w && j<=h 
    hist[i,j] += step
    return nothing #Success.
  end
  return (i,j) #Dropped off.
end
incorporate(h, x::Number,y::Number) = incorporate(h, x,y,1)

function gnuplot_write(h::Histogram2d, to::IOStream)
  w,h = size(h.hist)
  write(to, "#Histogram2d
#sx $(h.sx) sy $(h.sy) dx $(h.dx) dy $(h.dy) w $w h $h")
  for j = 1:h
    write(to, "\n\n$(h.hist[1,j])")
    for i = 2:w
      write(to, "\t$(h.hist[i,j])")
    end
  end
end

type Histogram2dExpanding
  range::(Float64,Float64, Float64,Float64) #Y maximum range.
  sx::Float64
  dx::Float64
  sy::Float64 #Y initially, each row has different one!
  dy::Float64 #Note that they're used as expanding histograms.
  arr::Array{(Float64,Array{Int64,1})}
end

function incorporate(h::Histogram2dExpanding, 
                     x::Number,y::Number, step::Integer)
  fx,fy, tx,ty = h.range
  if fx <= x <= tx &&  fy <= y <=ty #Check range.
    j,sy,arr = index_expand_if_needed(h.arr, h.sy,h.dy, y, 
                                     (h.sx, Array(Int64,0)))
    h.arr = arr
    i = int(floor((x - h.sx)/h.dx))
    h.arr[j][1] = sy
    h.arr[j][2][i] += step
  end
  return nothing
end

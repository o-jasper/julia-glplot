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
    Histogram2d(float64(fx),float64(fy), float64((tx-fx)/w),float64((ty-fy)/w),
                zero(Array(Int64, w,h)))

nnz(h::Histogram2d) = nnz(h.hist) #Non zero components.

function range(h::Histogram2d)
  w,h = size(h.hist)
  return (h.sx,h.sy, h.sx+h.dx*w, h.sy+h.dy*w)
end

incorporate(h, x::Number,y::Number) = incorporate(h, x,y,1)

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

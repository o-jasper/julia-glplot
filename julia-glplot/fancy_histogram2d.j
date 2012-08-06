#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Histograms that always register stuff, by expanding in some way.

type Histogram2dExpanding #Expands if things drop off.
  h::Histogram2d
end

Histogram2dExpanding(fx::Number,fy::Number, tx::Number,ty::Number,
                     w::Integer,h::Integer) = 
    Histogram2dExpanding(Histogram2d(fx,fy, (tx-fx)/w,(ty-fy)/w, w,h))

Histogram2dExpanding(sx::Number,sy::Number, dx::Number,dy::Number) =
    Histogram2dExpanding(Histogram2d(sx,sy, dx,dy, zero(Array(Int64,0,0))))

#_current_ range.
range(h::Histogram2dExpanding) = range(h.h)

function incorporate(h::Histogram2dExpanding, x::Number,y::Number, step::Integer)
  ret = incorporate(h.h, x,y,step)
  if ret!=nothing #If dropped off, expand it.
    i,j = ret
    w,h = size(h.h.hist)
    if i>0 && j>0 #Just resize it to have it fit in. 
      h.h.hist = reshape(h.h.hist, max(i,w), max(j,h))
      assert( h.h.hist[i,j] == 0 )
      h.h.hist[i,j] = step
    else #Will need to shift the data in the array.
      h.h.hist = reshape(h.h.hist, max(i,w,w-i), max(j,h,h-j))
      if i<0 
        h.h.sx += i*h.h.dx
      end
      if j<0 
        h.h.sx += j*h.h.dx
      end
      circshift(h.h.hist, i<0 ? -i : 0, j<0 ? -j : 0) #Neato, i have this!
      return incorporate(h, x,y,step) #Start anew.
    end
  end
  return nothing
end

#Expanding logarithmic histogram.
type Histogram2dLog
# (If 'zero included' things might otherwise screw up.)
  low_x::Float64 #Absolutes clamped above this. 
  low_y::Float64
  
  nxy::Histogram2dExpanding #Both x,y negative
  nx::Histogram2dExpanding #x negative
  ny::Histogram2dExpanding #y negative
  p::Histogram2dExpanding #both positive
end

function Histogram2dLog(low_x::Number,low_y::Number, ex::Number,ey::Number)
  he() = Histogram2dExpanding(0,0, float64(ex),float64(ey))
  return Histogram2dLog(float64(low_x),float64(low_y), he(),he(),he(),he())
end

Histogram2dLog(low::Number, e::Number) = Histogram2dLog(low,low, e,e)

#function range(h::Histogram2dLog) #TODO

function incorporate(h::Histogram2dLog, x::Number,y::Number, step::Integer)
#Histogram to put it in, absolutes
  put_in,ax,ay = x>0 ? (y>0 ? (h.p, x,y)   : (h.ny, x,-y)) :
                       (y>0 ? (h.nx, -x,y) : (h.nxy, -x,-y))
  return incorporate(put_in, log(max(low_x,ax)),log(max(low_y, ay)), step)
end

#Histogram with 'linear area' and expanding logarithmic area around.
type Histogram2dFancy
  lin_area::Histogram2d

  log::Histogram2dLog
end

Histogram2dFancy(fx::Number,fy::Number, tx::Number,ty::Number,
                 w::Integer,h::Integer, low_x::Number,low_y::Number, 
                 ex::Number,ey::Number) =
    Histogram2dFancy(Histogram2d(fx,fy, tx,ty, w,h),
                     Histogram2dLog(low_x,low_y, ex,ey))

Histogram2dFancy(fx::Number,fy::Number, tx::Number,ty::Number,
                 w::Integer,h::Integer, low::Number,e::Number) =
    Histogram2dFancy(fx,fy, tx,ty, w,h, low,low, e,e)

lin_range(h::Histogram2dFancy) = range(h.lin_area)
range(h::Histogram2dFancy) = range(h.log)

function incorporate(h::Histogram2dFancy, x::Number,y::Number, step::Integer)
  if incorporate(h.lin_area, x,y,step)!=nothing #If drops out
    return incorporate(h.log, x,y,step)
  end
end
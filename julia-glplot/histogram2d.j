#
#  Copyright (C) 16-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

typealias Field2d{Int64} Histogram2d

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
    write(to, "\n\n$(h.hist[1,j])") #Two newlines for each row.
    for i = 2:w
      write(to, "\t$(h.hist[i,j])")
    end
  end
end

type Histogram2dExpanding
  range::(Float64,Float64, Float64,Float64) #Y maximum range.
  sx::Float64
  sy::Float64 #Each row has different sy!
  dx::Float64
  dy::Float64 #Note that each array is used as expanding histograms.
  arr::Array{(Float64,Array{Int64,1})}
end

function max(h::Histogram2dExpanding) #TODO i don't like these..
  fz = mintype(Int64)
  for el in h.arr
    fz = max(fz, max(el[2]))
  end
  return fz
end
function min(h::Histogram2dExpanding) 
  tz = maxtype(Int64)
  for el in h.arr
    tz = min(tz, min(el[2]))
  end
  return tz
end

function incorporate(h::Histogram2dExpanding, 
                     x::Number,y::Number, step::Integer)
  fx,fy, tx,ty = h.range
  if fx <= x <= tx &&  fy <= y <=ty #Check range.
    j,sx,arr = index_expand_if_needed(h.arr, h.sy,h.dy, y, 
                                     (h.sx, Array(Int64,0)))
    h.arr = arr
    i = int(floor((x - h.sx)/h.dx))
    h.arr[j][1] = sx
    h.arr[j][2][i] += step
  end
  return nothing
end

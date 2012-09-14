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

size(h::Histogram2d) = size(h.hist)
max(h::Histogram2d) = max(h.hist)
min(h::Histogram2d) = min(h.hist)

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

function cur_fx(h::Histogram2d)
  fx,tx = typemax(Float64),typemin(Float64)
  for el in h.arr
    fx = min(fx, el[1])
  end
  return fx
end
cur_fy(h::Histogram2d) = h.sy
function cur_tx(h::Histogram2d)
  tx = typemin(Float64)
  for el in h.arr
    sx,arr = el 
    tx = max(tx, sx + h.dx*length(arr))
  end
  return tx
end
cur_ty(h::Histogram2d) = h.sy + h.dy*length(h.arr)

#Write output for gnuplot. 
#TODO make 1d histograms work the same way.
function gnuplot_write(h::Histogram2d, to::IOStream, 
                       range::(Number,Number, Number,Number))
  write(to, "#Histogram2d\n#s $(h.sx,h.sy) d $(h.dx,h.dy) "
  fx,fy, tx,ty = range
  function write_zeros(nx)
    for i = 1:nx
      write(to,"0\t")
    end
  end
  function write_zeros_lines(ny)
    nx = int((h.tx-h.fy)/h.dy)
    for j=1:ny
      write_zeros(nx)
      write(to,"\n\n")
    end
  end
  write_zeros_lines(max(0,int((h.sy-fy)/h.dy))) #y-leading zeros.
  to_j = int((ty-sy)/h.dy)
  actual_j = min(length(h.arr), to_j)
  for j = 1:actual_j
    sx,arr = h.arr[j]
    write_zeros(max(0,int((sx-fx)/h.dx))) #x-leading zeros.

    to_i = int((tx-sx)/h.dx)
    actual_i = min(length(arr), to_i) #The elements themselves
    for i = 1:actual_i
      write(to, "$(arr[i])\t")
    end
    write_zeros(max(0, to_i - actual_i) #x-zeros after.
  end
  write_zeros_lines(max(0, to_j - actual_j)) #y-zeros after.
end

gnuplot_write(h::Histogram2d, to::IOStream, max_range_p::Bool) = #!
    gnuplot_write(h,to, max_range ? h.max_range : cur_range(h))
gnuplot_write{R}(h::Histogram2d, to::String, range_something::R) = #!
    @with_open_file stream to "w" gnuplot_write(h,stream,range_something)
gnuplot_write{S}(h::Histogram2d, to::S) = #!
    gnuplot_write(h, to, true)


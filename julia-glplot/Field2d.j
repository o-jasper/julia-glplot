#
#  Copyright (C) 16-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type Field2d{IArr2d} #2D field. (indexable array 2d)
  sx::Float64 #Start.
  sy::Float64
  dx::Float64 #Step.
  dy::Float64 
  arr::IArr2d
end

Field2d(fx::Number,fy::Number, tx::Number,ty::Number,
        w::Integer,h::Integer, T) = 
    Field2d{IArr2d}(float64(fx),float64(fy), 
               float64((tx-fx)/w),float64((ty-fy)/w),
               zero(Array(T, w,h)))

size{IArr2d}(f::Field2d{IArr2d}) = size(f.arr)
max{IArr2d}(f::Field2d{IArr2d})  = max(f.arr) #Only for <:Number
min{IArr2d}(f::Field2d{IArr2d})  = min(f.arr)

ref{T,I<:Integer}(f::Field2d{IArr2d}, i::I,j::I) = f.arr[i,j]
assign{T,I<:Integer}(f::Field2d{IArr2d}, to::N, i::I,j::I) = #!
    (f.arr[i,j] = to)

ref{T,N<:Number}(f::Field2d{IArr2d}, x::N,y::N)   = 
    f.arr[int((x-f.sx)/f.dx), int((y-f.sy)/f.dy)]
set{T,N<:Number}(f::Field2d{IArr2d}, to::N, x::N,y::N) = #!
    (f.arr[int((x-f.sx)/f.dx), int((y-f.sy)/f.dy)] = to)

#TODO for <:Number the below.

#Write output for gnuplot. 
#TODO make 1d histograms work the same way.
#function gnuplot_write(f::Field2d, to::IOStream, 
#                       range::(Number,Number, Number,Number))
#  write(to, "#Field2d\n#s $(f.sx,f.sy) d $(f.dx,f.dy) "
#  fx,fy, tx,ty = range
#  function write_zeros(nx)
#    for i = 1:nx
#      write(to,"0\t")
#    end
#  end
#  function write_zeros_lines(ny)
#    nx = int((f.tx-f.fy)/f.dy)
#    for j=1:ny
#      write_zeros(nx)
#      write(to,"\n\n")
#    end
#  end
#  write_zeros_lines(max(0,int((f.sy-fy)/f.dy))) #y-leading zeros.
#  to_j = int((ty-sy)/f.dy)
#  actual_j = min(length(f.arr), to_j)
#  for j = 1:actual_j
#    sx,arr = f.arr[j]
#    write_zeros(max(0,int((sx-fx)/f.dx))) #x-leading zeros.
#
#    to_i = int((tx-sx)/f.dx)
#    actual_i = min(length(arr), to_i) #The elements themselves
#    for i = 1:actual_i
#      write(to, "$(arr[i])\t")
#    end
#    write_zeros(max(0, to_i - actual_i) #x-zeros after.
#  end
#  write_zeros_lines(max(0, to_j - actual_j)) #y-zeros after.
#end
#
#gnuplot_write(f::Field2d, to::IOStream, max_range_p::Bool) = #!
#    gnuplot_write(h,to, max_range ? f.max_range : cur_range(h))
#gnuplot_write{R}(f::Field2d, to::String, range_something::R) = #!
#    @with_open_file stream to "w" gnuplot_write(h,stream,range_something)
#gnuplot_write{S}(f::Field2d, to::S) = #!
#    gnuplot_write(h, to, true)
#

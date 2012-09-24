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

Field2d{IArr2d}(sx::Number,sy::Number, dx::Number,dy::Number, arr2d::IArr2d) =
    Field2d(float64(sx),float64(sy), float64(dx),float64(dy), arr2d)

#size{IArr2d}(f::Field2d{IArr2d}) = size(f.arr)

#Explicity ask for index.
ref_i{IArr2d}(f::Field2d{IArr2d}, i::Integer,j::Integer) =
    f.arr[i,j]
assign_i{T,IArr2d}(f::Field2d{IArr2d}, to::T, i::Integer,j::Integer) = #!
    (f.arr[i,j] = to)

max{IArr2d}(f::Field2d{IArr2d})  = max(f.arr) #Only for <:Number
min{IArr2d}(f::Field2d{IArr2d})  = min(f.arr)

ref{IArr2d}(f::Field2d{IArr2d}, x::Number,y::Number)   = 
    ref_i(f, int((x-f.sx)/f.dx), int((y-f.sy)/f.dy))
assign{T,IArr2d}(f::Field2d{IArr2d}, to::T, x::Number,y::Number) = #!
    assign_i(f, to, int((x-f.sx)/f.dx), int((y-f.sy)/f.dy))

#Iterating it. TODO make continuous iter work on it?
#Note: Gives you a row in the form of a Field{IArr}
start{IArr2d}(f::Field2d{IArr2d}) = start(f.arr)
done{IArr2d,State}(f::Field2d{IArr2d},s::State) = done(f.arr,s)
function next{IArr2d,State}(f::Field2d{IArr2d}, s::State)
  (i,v),next_state = next(f.arr,s)
 #Make it position, state.
  return ((f.sy + f.dy*i, Field(f.sx,f.dx, v)), next_state)
end

# `dlmwrite_iter` will write (x,y,value)'s, we want just z's, hence this:
# Actually, it basically for reading with gnuplot

#Write as matrix, not meant for sparse stuff!
function dlmwrite_any{IArr2d}(to::IOStream, f::Field2d{IArr2d}, 
                              delim::String,line_delim::String)
  write(to, "# sx $(f.sx) sy $(f.sy) dx $(f.dx) dy $(f.dy)\n")
  si,sj = min_i(f.arr),min_j(f.arr)
  write(to, "# si $si sj $sj\n")
  for i = si:max_i(f.arr)
    for j = sj:max_j(f.arr)
      write(to, "$(ref_i(f, i,j))$delim")
    end
    write(to, line_delim)
  end
end

dlmwrite_any{IArr2d}(file::String, f::Field2d{IArr2d}) = 
    @with stream = open(file,"w") dlmwrite_any(stream, f, "\t","\n")

#Write it as a list of points.
function dlmwrite_pointlist{IArr2d}(to::IOStream, f::Field2d{IArr2d}, 
                              between_delim::String, delim::String,
                              line_delim::String)
  for row in f
    x,f = row
    for el in f
      y,v = el
      write(to, "$x$between_delim$y$between_delim$v$delim")
    end
    write(to, line_delim)
  end
end
dlmwrite_pointlist{IArr2d}(file::String, f::Field2d{IArr2d}, 
                           between_delim::String, delim::String,
                           line_delim::String) =
    @with stream = open(file,"w") dlmwrite_pointlist(stream,f,between_delim,
                                                     delim, line_delim)

dlmwrite_pointlist{IArr2d,To}(to::To, f::Field2d{IArr2d}) =
    dlmwrite_pointlist(to, f, "\t","\n","\n\n")

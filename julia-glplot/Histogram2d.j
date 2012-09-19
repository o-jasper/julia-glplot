#
#  Copyright (C) 16-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Getting the x/y histogram, field passes it on to the IArr2d.(lame huh)
function hist_x{N<:Number}(input::ExpandingArray2d{N})
  arr = ExpandingArray(N) #Initiate the array.
  for row_in in input
    i,row = row_in
    for value in indexless_iter(row) #don't care about indices now.
      arr[i] += value #Incorporate.
    end
  end
  return arr
end
function hist_y{N<:Number}(input::ExpandingArray2d{N})
  arr = ExpandingArray(N) #Initiate the array.
  for row in indexless_iter(input) #Not caring about indices of x now.
    for el in row
      j,value = el
      arr[j] += value #Incorporate.
    end
  end
  return arr
end

#Field Stuff.
incorporate(h, x::Number,y::Number) = incorporate(h, x,y,1)
incorporate(h, pos::(Number,Number),step) = incorporate(h, pos[1],pos[2],step)
incorporate(h, pos::(Number,Number)) = incorporate(h, pos,1)
incorporate{N<:Number, IArr2d}(f::Field2d{IArr2d}, x::N,y::N, step) = #!
    (f[x,y] += step)

#Getting the x/y histogram, field passes it on to the IArr2d.(lame huh)
hist_x{IArr2d}(f::Field2d{IArr2d}) = Field(f.sx,f.dx, hist_x(f.arr))
hist_y{IArr2d}(f::Field2d{IArr2d}) = Field(f.sy,f.dy, hist_y(f.arr))

#Finally the histogram adding the range.
type Histogram2d{IArr2d}
  range::(Float64,Float64, Float64,Float64) 
  field::Field2d{IArr2d}
end

#size{IArr2d}(h::Histogram2d{IArr2d}) = size(h.field)
max{IArr2d}(h::Histogram2d{IArr2d})  = max(h.field) 
min{IArr2d}(h::Histogram2d{IArr2d})  = min(h.field)

function incorporate{IArr2d}(h::Histogram2d{IArr2d}, x,y, step)
  fx,fy, tx,ty = h.range
  return (fx<=x<=tx &&  fy<=y<=ty) ? incorporate(h.field, x,y,step) : nothing
end

#Iterating it.
start{IArr}(h::Histogram2d{IArr}) = start(h.field)
done{IArr,State}(h::Histogram2d{IArr},s::State) = done(h.field,s)
next{IArr,State}(h::Histogram2d{IArr},s::State) = next(h.field,s)

dlmwrite_any{To,IArr2d}(to::To, h::Histogram2d{IArr2d},
                        between_delim::String, delim::String,
                        line_delim::String) =
    dlmwrite_any(to, h, between_delim,delim,line_delim)

#For x and y histograms, it just lets Field2d do the work and passes on the 
#range.
hist_x{IArr2d}(h::Histogram2d{IArr2d}) = 
    Histogram(h.range[1],h.range[3], hist_x(h.field))
hist_y{IArr2d}(h::Histogram2d{IArr2d}) = 
    Histogram(h.range[2],h.range[4], hist_y(h.field))

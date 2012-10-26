#
#  Copyright (C) 16-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#TODO completely untested!
#Note: BoundsErrors automatic.

type Field{IArr} #1D field. (IArr short of indexable array)
  s::Float64 #Start.
  d::Float64 #Step.
  arr::IArr
end

Field{IArr}(s::Number,d::Number, arr::IArr) =
    Field(float64(s),float64(d),arr)

length{IArr}(f::Field{IArr}) = length(f.arr)
#size{IArr}(f::Field{IArr})   = size(f.arr)
max{IArr}(f::Field{IArr})  = max(f.arr) #Only for <:Number
min{IArr}(f::Field{IArr})  = min(f.arr)

ref_i{I<:Integer,IArr}(f::Field{IArr}, i::I) = f.arr[i]

ref{N<:Number,IArr}(f::Field{IArr}, x::N) = ref_i(f, int((x-f.s)/f.d))
assign{T,N<:Number,IArr}(f::Field{IArr}, to::T, x::N) = #!
    (f.arr[int((x-f.s)/f.d)] = to) 

#All this index getting stuff is a bit private.
ref{I<:Integer,IArr}(f::Field{IArr}, i::I) = f.arr[i]
assign{T,I<:Integer,IArr}(f::Field{IArr}, to::T, i::I) = (f.arr[i] = to) #!

i_at{N<:Number,IArr}(f::Field{IArr}, x::N) = int((x-f.s)/f.d)
x_at{I<:Integer,IArr} (f::Field{IArr}, i::I) = f.s + f.d*i
pos_at{I<:Integer,IArr} (f::Field{IArr}, i::I) = (f.s + f.d*i, f.arr[i])

#Iterating it. 
start{IArr}(f::Field{IArr}) = start(f.arr)
done{IArr,State}(f::Field{IArr},s::State) = done(f.arr,s)
function next{IArr,State}(f::Field{IArr},s::State)
  (i,v),next_state = next(f.arr,s)
  return ((f.s + f.d*i, v), next_state) #Make it position, state.
end

function dlmwrite_any{IArr}(to::IOStream, f::Field{IArr}, 
                            delim::String,line_delim::String)
  write(to, "# s $(f.s) d $(f.d)\n")
  write(to, "# si $(min_i(f.arr))\n")
  dlmwrite_any(to, f.arr,delim,line_delim)
end

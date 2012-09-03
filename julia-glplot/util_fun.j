#
#  Copyright (C) 31-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Functions the other stuff needs.

function propagate_flip(arr::Array{(Float64, Uint8),1}, base::Uint8, 
                        fy::Number, w::Number, abs_first::Bool)
  if isempty(arr)
    push(arr, (fy, uint8(0)))
  end
  y1,c1 = arr[1]
  if c1-1<base #First one doesn't flip anything, just count and set it.
    arr[1] = (abs_first ? fy :(w*fy + y1)/(w+1), uint8(c1+1))
    return 0
  else #Flip and propagate.
    arr[1] = (abs_first ? fy : (w*fy + y1)/(w+1), uint8(0))
  end
  i=1
  while true
    yc,c = arr[i]
    i+=1
    if i > length(arr) #Have to initiate a new entry.
      push(arr, (yc,uint8(0)))
      return i
    end
    y,c = arr[i] #Look at y and count.
    arr[i] = ((w*y+yc)/(w+1), uint8(c+1))
    if c < base #Not flipping next one yet, done.
      return i
    end #Flip next one, average current one with next one.
    arr[i] = (y,uint8(0)) #Reset current counter.
  end
end
propagate_flip(arr::Array{(Float64, Uint8),1}, base::Uint8, 
               fy::Number, w::Number) =
    propagate_flip(arr,base, fy,w, true)

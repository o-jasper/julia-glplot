#
#  Copyright (C) 31-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Averages together averages over powers of time.
type PlotPwr
  times_per::Uint8
  duration:Float64
  next_x::Float64
  data::Array{(Float64, Uint8),1}
  last_i::Uint16
  function PlotPwr(times_per::Integer, duration::Number)
    @assert times_per< 256 && times_per>=2 
    @assert duration>0
    return new(uint8(times_per), float64(duration),mintype(Float64),
               [(float64(0),false)], uint16(0))
  end
end

PlotPwr(duration::Number) = PlotPwr(2,duration)

function propagate_flip(arr::Array{(Float64, Bool),1}, times_per::Uint8)
  y,times = arr[1]
  if length(arr)<2 #Extend if needed.
    push(arr, (float64(y/2),uint8(1))) #Know what to fill it with then.
  else
    y2,times = arr[2] #Otherwise average with it and maybe continue.
    arr[2] = ((y+y2)/2, (times+1)%times_per)
    if times+1 >= times_per #Effectively it counts up with time_per as base.
      return 1+propagate_flip(arr[2:])
    end
  end
  return 0
end

function incorporate(into::PlotPwr, x::Number, y::Number,w::Number)
  cy, flip= into.data[1]
  into.data = (w*y + cw*cy, flip)
  if x > into.next_x #Need to propagate.
    into.next_x = x + into.duration
    last_i = propagate_flip(into.data, into.times_per)
    into.data[1] = (float64(0),0) #Reset the first one.
    return last_i
  end
  return 0
end
incorporate(into::PlotPwr, x::Number, y::Number) = incorporate(into, x,y,1)

#PlotPwr making histograms aswel.(Which, conveniently can be choosen.
type PlotPwrHist{H}
  p::PlotPwr
  h::Array{H,1}
  z::H #The 'zero histogram' to copy making a new one.
  PlotPwrHist(p::PlotPwr, z::H) = 
      new(p,[copy(z)],z, Array(Bool,0))
end
#NOTE: i think no constructor really adds anything.

function incorporate{H}(into::PlotPwrHist{H}, x::Number, y::Number,w::Number)
  last_i = incorporate(into.p, x,y,w)
  for i = 1:min(length(into.state), last_i) 
    local y,c = into.p.data[i] #Everything below `last_i` is new.
    incorporate(into.h[i], y)
  end
  if last_i>length(into.state) #List of histograms not long enough.
    hist = copy(into.zero)
    push(into.state, hist) #Make copy from zero histogram and incorporate.
    local y,c = last(into.p.data)
    incorporate(hist, y)
  end
end

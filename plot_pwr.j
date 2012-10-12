#
#  Copyright (C) 31-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#NOTE: probably this whole thing will get deleted!

#Averages together averages over powers of time.
type PlotPwr
  base::Uint8
  duration::Float64
  next_x::Float64
  data::Array{(Float64, Uint8),1}
  last_i::Uint16

  cur_y::Float64
  cur_w::Float64

  prop_w::Float32
  function PlotPwr(base::Integer, duration::Number)
    @assert base< 256 && base>=2 
    @assert duration>0
    return new(uint8(base), float64(duration),typemin(Float64),
               Array((Float64,Uint8),0), uint16(0), 
               float64(0),float64(0),
               float64(1))
  end
end

PlotPwr(duration::Number) = PlotPwr(2,duration)

function incorporate(into::PlotPwr, x::Number, y::Number,w::Number)
  into.cur_y = (into.cur_y + w*y)/(1+w)
  i=0
  if x > into.next_x #Need to propagate.
    for j = 1:int(1 + (x - into.next_x)/into.duration)
      i = max(i, propagate_flip(into.data, into.base, into.cur_y,into.prop_w))
    end
    into.next_x = x + into.duration
  end
  return i
end
#NOTE: it might not make sense to change the weight..
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
    local cy,c = into.p.data[i] #Everything below `last_i` is new.
    incorporate(into.h[i], cy)
  end
  if last_i>length(into.state) #List of histograms not long enough.
    hist = copy(into.zero)
    push(into.state, hist) #Make copy from zero histogram and incorporate.
    local cy,c = last(into.p.data)
    incorporate(hist, cy)
  end
end

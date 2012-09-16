#
#  Copyright (C) 14-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Logarithmic histogram. (The log typically dampens the memory use a lot)
type HistogramLog{IArr}
  low::Float64
  n::Field{IArr}
  p::Field{IArr}
end

HistogramLog(low::Number, d::Number, I) =
    HistogramLog(float64(low), 
                 Field(0,d, ExpandingArray(I)), 
                 Field(0,d, ExpandingArray(I)))

HistogramLog(low::Number, d::Number) = HistogramLog(low,d, Int64)

length(h::HistogramLog) = length(h.n) + length(h.p)

max(h::HistogramLog) = max(h.n,h.p)
min(h::HistogramLog) = min(h.n,h.p)

#range_of(h::HistogramExpanding) = #No clear plot range.(everything?)
#plot_range_of(h::HistogramExpanding) = plot_range_of(h.h)

function incorporate(h::HistogramLog, x::Number, step::Integer)
  if x>0
    incorporate(h.p, log10(max(x, h.low)), step)
  else
    incorporate(h.p, log10(max(-x, h.low)), step)
  end
end

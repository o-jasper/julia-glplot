
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

length{IArr}(h::HistogramLog{IArr}) = length(h.n) + length(h.p)

max{IArr}(h::HistogramLog{IArr}) = max(h.n,h.p)
min{IArr}(h::HistogramLog{IArr}) = min(h.n,h.p)

#No clear plot range.(everything?)
#range_of{IArr}(h::HistogramExpanding{IArr}) = 
#plot_range_of{IArr}(h::HistogramExpanding{IArr}) = plot_range_of(h.h)

function incorporate{IArr}(h::HistogramLog{IArr}, x::Number, step::Integer)
  if x>0
    incorporate(h.p, log10(max(x, h.low)), step)
  else
    incorporate(h.p, log10(max(-x, h.low)), step)
  end
end

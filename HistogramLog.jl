
#Logarithmic histogram. (The log typically dampens the memory use a lot)
type HistogramLog{IArr}
  low::Float64
  n::Field{IArr}
  p::Field{IArr}
end

HistogramLog(low::Number, d::Number, I) =
    HistogramLog(float64(low), 
                 Field(0,-d, ExpandingArray(I)), 
                 Field(0,d, ExpandingArray(I)))

HistogramLog(low::Number, d::Number) = HistogramLog(low,d, Float64)

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
    incorporate(h.n, log10(max(-x, h.low)), step)
  end
end

#Iterator, boolean is if negative/positive.
start{IArr}(h::HistogramLog{IArr}) = (start(h.n),false)
done{IArr,State}(h::HistogramLog{IArr},s::(State,Bool)) =
    (s[2] && done(h.p,s[1]))
function next{IArr,State}(h::HistogramLog{IArr}, s::(State,Bool))
    n(v) = (-(10^v[1]),v[2])
    p(v) = (+(10^v[1]),v[2])
    if s[2] #Positives
        v,state = next(h.p,s[1])
        return (p(v), (state,true))
    elseif done(h.n,s[1]) #Starting the positives.
        v,state = next(h.p, start(h.p))
        return (p(v), (state,true))
    else #Negatives
        v,state = next(h.n,s[1])
        return (n(v), (state,false))
    end
end

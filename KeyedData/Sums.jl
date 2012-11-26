#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Summing stuff about variables. TODO, can stuff be added?

type SingleSum #Sums about single key.
    sum::Float64
    sum_sqr::Float64
    cnt::Float64
end
SingleSum(h) = SingleSum(h, float64(0),float64(0),float64(0))
SingleSum(low::Number,d::Number,I) = SingleSum(HistogramLog(low,d,I))
SingleSum(low::Number,d::Number) = SingleSum(HistogramLog(low,d,Float64))o
SingleSum() = SingleSum(nothing)

average(accum::SingleSum) = accum.sum/accum.cnt
sigma(accum::SingleSum)   = (accum.sqr_sum - accum.sum^2/accum.cnt)/accum.cnt

function incorporate(accum::SingleSum, x,step)
    accum.sum += step*x
    accum.sum_sqr += step*x^2
    accum.cnt += step
    if !is(accum.h,nothing)
        incorporate(accum.h, x,step)
    end
end
incorporate(accum::SingleSum, x::Number) = incorporate(accum,x, 1)

type PairSum #Sums about pair of keys.
    sum_xy::Float64
    cnt::Float64
end

function incorporate(pa::PairSum, x,y,step)
    pa.sum_xy += step*x*y
    pa.cnt += step
end
incorporate(pa::PairSum, x,y,step) = incorporate(pa, x,y,1)

function correlation(xy::PairSum, x::SingleSum,y::SingleSum)
    return( (pa.cnt*pa.sum_xy - x.sum*y.sum) /
            (pa.cnt*sqr(x.sum_sqr - x.sum^2)*(y.sum_sqr - y.sum^2)) )
end

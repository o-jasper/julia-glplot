
#Iterable (x)ticks.
type RangeTicks
    fr::Float64
    to::Float64
    factors::Array{Int8,1}
    exp::Float64

    function RangeTicks(fr::Float64,to::Float64, factors::Array{Int8,1})
#        mult = float64(1)
#        for el in factors
#            mult*=el
#        end
        new(fr,to,factors, factors[1])
    end
end
RangeTicks(fr::Number,to::Number, factors) = 
    RangeTicks(float64(fr),float64(to), int8(factors))
RangeTicks(fr::Number,to::Number) = RangeTicks(fr,to, [10,5,1])

start(t::RangeTicks) = t.fr
function next(rt::RangeTicks, x::Float64)
    if rt.to==rt.fr 
        return ((rt.to, int8(0)), rt.to)
    end
    dsize = floor(log(abs(rt.to-rt.fr))/log(rt.exp))
    d = rt.exp^(dsize-1)
    n = int(floor(x/d)) + 1
    while d*n < rt.to
        for i = 1:length(rt.factors)
            if (n%rt.factors[i])==0 && d*n>x
                return ((d*n,int8(i)), d*n) #Value is x and 'level' of the tick.
            end
        end
        n+=1
    end
    return ((d*n,int8(0)), d*n)
end
done(rt::RangeTicks, x::Float64) = (x >= rt.to)
#done(rt::RangeTicks, x) = (x >= rt.to)

#Double iterable x,y ticks.
type XYRangeTicks
    x::RangeTicks
    y::RangeTicks
end

function XYRangeTicks(range::(Number,Number,Number,Number), factors_x,factors_y)
    fx,fy,tx,ty = range
    return XYRangeTicks(RangeTicks(fx,tx, factors_x), 
                        RangeTicks(fy,ty, factors_y))
end

XYRangeTicks(range::(Number,Number,Number,Number), factors) = 
    XYRangeTicks(range, factors,factors)
XYRangeTicks(range::(Number,Number,Number,Number)) = 
    XYRangeTicks(range, [10,5,1])

start(t::XYRangeTicks) = (start(t.x), start(t.y)) #==(t.x.fr, t.y.fr)
function next(pos::(Float64,Float64), t::XYRangeTicks)
    x,nx = next(t.x,pos[1])
    if done(t.x,x)
        x = start(t.x) #Reset x, forward y.
        y,ny = next(t.y,y)
        return ((x,y), t)
    end
    return ((x,pos[2]),t)
end

done(pos::(Float64,Float64), t::XYRangeTicks) = done(pos[2], t.y)

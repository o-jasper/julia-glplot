#Histogram with linear part and expanding logarithmic around.
#(records all)
type HistogramLinArea
  lin_area::Histogram
  log::HistogramLog
end

max(h::HistogramLinArea) = max(h.lin_area,h.log)
min(h::HistogramLinArea) = min(h.lin_area,h.log)

HistogramLinArea(fr::Number,to::Number, n::Integer, low::Number,e::Number) =
    HistogramLinArea(Histogram(fr,to,n),HistogramLog(low,e))

HistogramLinArea(fr::Number,to::Number, n::Integer, e::Number) =
    HistogramLinArea(fr,to, n, (to-fr)/n, e)
HistogramLinArea(fr::Number,to::Number, n::Integer) =
    HistogramLinArea(fr,to, n, 2/n)

function incorporate(h::HistogramLinArea, x::Number, step::Integer)
  if is(incorporate(h.lin_area, x,step), nothing) #If drops out
    return incorporate(h.log, x,step)
  end
end

plot_range_of(h::HistogramLinArea) = plot_range_of(h.lin_area)

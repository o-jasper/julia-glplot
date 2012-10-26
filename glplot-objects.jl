
#NOTE: all `export`ing and such shall be here. No tricks here.

module JuliaGLPlotObjects
#Just the objects for plotting without dependency to opengl or plotting 
# facility (JuliaGLPlot does that)

import Base.*, OptionsMod.*
import OJasper_Util.*, ExpandingArrayModule.*, DlmWriteIter.*

load("julia-glplot/range.jl")

load("julia-glplot/Field.jl")
load("julia-glplot/Field2d.jl")
export Field,Field2d, ref_i

load("julia-glplot/Histogram.jl")
load("julia-glplot/HistogramLog.jl")
load("julia-glplot/HistogramLinArea.jl")
export Histogram,HistogramLog,HistogramLinArea,
       incorporate, plot_range_of, inform_of_range

load("julia-glplot/PlotPath.jl")
export PlotPath

load("julia-glplot/ContinuousSeq.jl")
export ContinuousSeq, ContinuousSeqIter, hist_now

#inform_of_range,value_at
end


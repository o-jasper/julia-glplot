
#NOTE: all `export`ing and such shall be here. No tricks here.

module JuliaGLPlotObjects
#Just the objects for plotting without dependency to opengl or plotting 
# facility (JuliaGLPlot does that)

import Base.*
import OJasper_Util.*
import ExpandingArrayModule.*
import DlmWriteIter.*

include("../Field.j")
include("../Field2d.j")
export Field,Field2d, ref_i

include("../Histogram.j")
include("../HistogramLog.j")
include("../HistogramLinArea.j")
export Histogram,HistogramLog,HistogramLinArea,
       incorporate, plot_range_of, inform_of_range

include("../PlotPath.j")
export PlotPath
#inform_of_range,value_at
end


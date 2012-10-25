

module JuliaGLPlot
#Just the objects for plotting without dependency to opengl or plotting 
# facility (JuliaGLPlot does that)

import Base.*, OptionsMod.*
import OJasper_Util.*, Geom.*, ExpandingArrayModule.*

import JuliaGLPlotObjects.*

import AutoFFI_GL.*, FFI_Extra_GL.*
import JuliaGLPlot.*

include("../gl_plot.j")
export gl_plot_under, gl_plot, gl_plot_filled_box,
       gl_plot_bar_intensity, plot_grayscale_color
#interpolate_color
include("../gl_plot_histogram.j")
include("../gl_PlotPath.j")

include("../gl_plot_ContinuousSeq.j")
end


module JuliaGLPlot
#Just the objects for plotting without dependency to opengl or plotting 
# facility (JuliaGLPlot does that)

import Base.*
import OJasper_Util.*
import Geom.*
import ExpandingArrayModule.*

import JuliaGLPlot.*

import AutoFFI_GL.*
import FFI_Extra_GL.*

import JuliaGLPlotObjects.*

include("../gl_plot.j")
export gl_plot_under, gl_plot, gl_plot_filled_box,
       gl_plot_bar_intensity, plot_grayscale_color
#interpolate_color
include("../gl_plot_histogram.j")

include("../gl_PlotPath.j")

#NOTE: some of these will get deleted completely!
include("../util_fun.j") 
include("../plot_pwr.j")
include("../gl_plot_pwr.j")
include("../gl_plot_continuous.j")
export ContinuousPlot, FancyContinuousPlot,  
       timestep, cur_x

end
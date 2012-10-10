#
#  Copyright (C) 16-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#NOTE gl_plot_filled_box(Histogram,(NNNN),Number) works by a generic function
# in plot_gl.j!

gl_plot{IArr}(h::Histogram{IArr},
              range::(Number,Number,Number,Number), box_to::Number) =
    gl_plot_box(h, range, box_to)
gl_plot{IArr}(h::Histogram{IArr}, range::(Number,Number,Number,Number)) = 
    gl_plot(h,range, range[2])

gl_plot{IArr}(h::Histogram{IArr}, box_to::Number) = 
    gl_plot(h,plot_range_of(h), box_to)
gl_plot{IArr}(h::Histogram{IArr}) =
    gl_plot(h,plot_range_of(h), min(h))

#Generic guys to fit on all the histograms.(and more?)

#plot
#filled_box
gl_plot_filled_box{H}(h::H, range::(Number,Number,Number,Number)) = 
    gl_plot_filled_box(h,range, range[2])

gl_plot_filled_box{H}(h::H, box_to::Number) = 
    gl_plot_filled_box(h,plot_range_of(h), box_to)
gl_plot_filled_box{H}(h::H) = 
    gl_plot_filled_box(h,plot_range_of(h), min(h))
#plot_under
#gl_plot_under{H}(h::H, range::(Number,Number,Number,Number)) =
#    gl_plot_under(h,range)

gl_plot_under{H}(h::H,to::Number) = gl_plot_under(h,plot_range_of(h),to)
gl_plot_under{H}(h::H)            = gl_plot_under(h,plot_range_of(h), 0)

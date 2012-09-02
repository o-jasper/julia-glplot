#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#This should be enough to establish the various kinds of plotting.
pos(h::Histogram,i::Integer) = h.s + i*h.d, h.hist[i]
done(h::Histogram,i::Integer) = (i>=length(h.hist))

#Expanding histograms refer on.
pos(h::HistogramExpanding,i::Integer) = pos(h.h,i)
done(h::HistogramExpanding,i::Integer) = done(h.h,i)

#HistogramLog cannot be unambigously done; it is two histograms

#Histogram just plots the linear area.
pos(h::HistogramFancy,i::Integer) = pos(h.lin_area,i)
done(h::HistogramFancy,i::Integer) = done(h.lin_area,i)

#NOTE gl_plot_filled_box(Histogram,(NNNN),Number) works by a generic function
# in plot_gl.j!

typealias HistogramTypes Union(Histogram,HistogramExpanding)

#HistogramExpanding has to tell it to look at the Histogram object inside.
gl_plot(h::HistogramExpanding, range::(Number,Number,Number,Number), 
        box_to::Number) =
    gl_plot_box(h.h, range, box_to)

gl_plot(h::HistogramTypes,
        range::(Number,Number,Number,Number), box_to::Number) =
    gl_plot_box(h, range, box_to)
gl_plot(h::HistogramTypes, range::(Number,Number,Number,Number)) = 
    gl_plot(h,range, range[2])

gl_plot(h::HistogramTypes, box_to::Number) = 
    gl_plot(h,plot_range_of(h), box_to)
gl_plot(h::HistogramTypes) =
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
gl_plot_under{H}(h::H, range::(Number,Number,Number,Number)) =
    gl_plot_under(h,range)

gl_plot_under{H}(h::H,to::Number) = gl_plot_under(h.hist,plot_range_of(h),to)
gl_plot_under{H}(h::H)            = gl_plot_under(h,plot_range_of(h))
gl_plot_above{H}(h::H)            = gl_plot_above(h,plot_range_of(h))

#bar_intensity.
gl_plot_bar_intensity{YRange,H}(h::H, yr::YRange,
                           colors::Array{(Number,Number,Number),1}) =
    gl_plot_bar_intensity(h, yr, plot_range_of(h), colors)

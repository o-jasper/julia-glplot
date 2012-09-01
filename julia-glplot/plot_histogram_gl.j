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

# gl_plot establishes defaults.

gl_plot(h::Histogram, range::(Number,Number,Number,Number), box_to::Number) =
    gl_plot_box(h, range, box_to)

gl_plot(h::Histogram, range::(Number,Number,Number,Number)) = 
    gl_plot(h,range, range[2])

gl_plot(h::Histogram, box_to::Number) = gl_plot(h,plot_range_of(h), box_to)
gl_plot(h::Histogram) = gl_plot(h,plot_range_of(h), min(h))

#Extend filled box.
#NOTE gl_plot_filled_box(Histogram,(NNNN),Number) works by a generic function
# in plot_gl.j!
gl_plot_filled_box(h::Histogram, range::(Number,Number,Number,Number)) = 
    gl_plot_filled_box(h,range, range[2])

gl_plot_filled_box(h::Histogram, box_to::Number) = 
    gl_plot_filled_box(h,plot_range_of(h), box_to)
gl_plot_filled_box(h::Histogram) = 
    gl_plot_filled_box(h,plot_range_of(h), min(h))

gl_plot_under(h::Histogram, range::(Number,Number,Number,Number)) =
    gl_plot_under(h,range)

gl_plot_under(h::Histogram,to::Number) = 
    gl_plot_under(h.hist,plot_range_of(h),to)
gl_plot_under(h::Histogram) = gl_plot_under(h,plot_range_of(h))
gl_plot_above(h::Histogram) = gl_plot_above(h,plot_range_of(h))

#And empty box.
gl_plot(h::HistogramExpanding, range::(Number,Number,Number,Number), 
        box_to::Number) =
    gl_plot(h.h, range, box_to)

gl_plot(h::HistogramExpanding, range::(Number,Number,Number,Number)) =
    gl_plot(h.h, range, range[2])

#TODO code repeat..
gl_plot(h::HistogramExpanding, box_to::Number) =
     gl_plot(h,plot_range_of(h), box_to)
gl_plot(h::HistogramExpanding) = gl_plot(h,plot_range_of(h), min(h))

    
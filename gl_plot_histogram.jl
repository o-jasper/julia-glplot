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

function gl_plot{IArr}(h::Histogram{IArr}, opts::Options)
    @defaults opts to = 0
    @set_options opts to = to
    gl_plot_box(h, opts)
end

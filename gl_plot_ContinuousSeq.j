#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Uses the iterator to plot the thing.
function gl_plot{K}(cp::ContinuousSeq{K}, i::K,j::K, opts::Options)
    @defaults opts mode = GL_LINE_STRIP time = time()
    @defaults opts aim_range = nothing
    @defaults opts range = aim_range==nothing ?
                           plot_range_of(cp, i,j) :
                           plot_range_of(cp, i,j, aim_range)
    gl_plot(mode,iter, opts)
end
gl_plot{K}(cp::ContinuousSeq{K}, i::K,j::K) = gl_plot(cp, i,j, @options)
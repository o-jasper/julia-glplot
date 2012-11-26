#
#  Copyright (C) 22-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#If given keys or lists of keys, currently simply plot them.
gl_plot{K}(kd::KeyedData{K}, ij::Union((K,K),Vector{(K,K)},(K,Vector{K})), opts::Options) =
    gl_plot(kd.seq, ij, opts)
gl_plot{K}(kd::KeyedData{K}, ij::Union((K,K),Vector{(K,K)},(K,Vector{K}))) =
    gl_plot(kd, ij, @options)

gl_plot_bar_intensity{K}(kd::KeyedData{K}, ij::Union((K,K),Vector{(K,K)},(K,Vector{K})), 
                         opts::Options) =
    gl_plot(kd.seq, ij, opts)
gl_plot_bar_intensity{K}(kd::KeyedData{K}, ij::Union((K,K),Vector{(K,K)},(K,Vector{K}))) =
    gl_plot(kd, ij, @options)

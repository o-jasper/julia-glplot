#
#  Copyright (C) 24-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#TODO combining multiple ranges.

#Uses the iterator to plot the thing.
function gl_plot{K}(cp::ContinuousSeq{K}, ij::(K,K), opts::Options)
    @defaults opts mode = GL_LINE_STRIP 
    @defaults opts range = plot_range_of(cp, ij, opts)
    @set_options opts range = range
    gl_plot(mode,ContinuousSeqIter(cp,ij), opts)
end
#Multiple at a time.
function gl_plot{K}(cp::ContinuousSeq{K}, ij::Vector{(K,K)}, opts::Options)
    @defaults opts range = plot_range_of(cp, ij, opts)
    @set_options opts range = range
    for el in ij
        gl_plot(cp, el, opts)
    end
end
#Multiple at a time, consistently same variable in x param.
gl_plot{K}(cp::ContinuousSeq{K}, ij::(K,Vector{K}), opts::Options) =
    gl_plot(cp, map((j)->(ij[1],j), ij[2]), opts)

gl_plot{K,IJ}(cp::ContinuousSeq{K}, ij::IJ) = gl_plot(cp, ij, @options)

#Uses the iterator to plot the thing.
function gl_plot_bar_intensity{K}(cp::ContinuousSeq{K}, ij::(K,K),
                                  opts::Options)
    @defaults opts range = plot_range_of(cp, ij, opts)
    @set_options opts range = range
    gl_plot_bar_intensity(ContinuousSeqIter(cp,ij), opts)
end

function gl_plot_bar_intensity{K}(cp::ContinuousSeq{K}, ij::Vector{(K,K)}, 
                                  opts::Options)
    @defaults opts range = plot_range_of(cp, ij, opts)
    @set_options opts range = range
    len = length(ij)
    glscale(1,1/len)
    @with glpushed() for el in ij
        gltranslate(0,1)
        gl_plot_bar_intensity(ContinuousSeqIter(cp,el), opts)
    end
end

gl_plot_bar_intensity{K}(cp::ContinuousSeq{K}, ij::(K,Vector{K}), 
                         opts::Options) =
    gl_plot_bar_intensity(cp, map((j)->(ij[1],j), ij[2]), opts)

gl_plot_bar_intensity{K,IJ}(cp::ContinuousSeq{K}, ij::IJ) =
    gl_plot_bar_intensity(cp, ij, @options)

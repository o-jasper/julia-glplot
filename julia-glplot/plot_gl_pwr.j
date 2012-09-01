#
#  Copyright (C) 31-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Should be enough.
pos(p::PlotPwr, i::Integer)  = (i, p.data[i][1])
length(p::PlotPwr) = length(p.data)
done(p::PlotPwr, i::Integer) = (i > length(p))

#TODO bar intensity plot in plot_gl and then multiple of those
# for PlotPwrHist{H}
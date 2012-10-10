#
#  Copyright (C) 10-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Uses linear fit (Mx=y) to figure out resistances in series.
# Resistors not in series is not a linear problem.
type ResistorSeriesScan
  mfp::MatrixFitProcess
end

function ResistorSeriesScan(cnt::Integer)
  ResistorSeriesScan(MatrixFitProcess(1,cnt))
end

cnt(rss::ResistorSeriesScan) = length(rss.mfp.xx)
#Takes into account the resistance of some set of resistors.
function incorporate!(rss::ResistorSeriesScan, 
                      involved::Vector{Int16}, 
                      resistance::Float64,error::Float64)
  x = fill(float64(0),cnt(rss)) #Note Array(Float64,...) doesnt zero it
  for i= 1:length(involved)
    x[involved[i]] = 1
  end
  return incorporate!(rss.mfp, x,[resistance], error^-2)
end
#function incorporate!(rss::ResistorSeriesScan, involved::Vector{Integer},
 #                     resistance::Number,error)
#  return incorporate!(rss, int16(involved), float64(resistance),
#                      float64(error==nothing ? 1 : error))
#end

#TODO produces an 1xN array not a N array which is what i want..
result(rss::ResistorSeriesScan) = result(rss.mfp)

#TODO linear-approximation based for resistors not in series?
# ... or something, could also try numerically minimalize from there.
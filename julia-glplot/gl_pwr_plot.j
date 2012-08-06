#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type PwrPlot
  duration:Float64
  weight::Float64
  data::Array{(Float64,Float64),1}
end

PwrPlot(duration::Number, weight::Number) = 
    PwrPlot(float64(duration),float64(weight),Array((Float64,Float64),0))

#Hmm, TODO how does this idea work with random times
#incorporate(pp::PwrPlot, 
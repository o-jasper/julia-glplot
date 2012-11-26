
module KeyedData_Objs

import Base.*, OptionsMod.*
import OJasper_Util.*
import JuliaGLPlotObjects.*

load("julia-glplot/KeyedData/KeyedData.jl")
export KeyedData, get_data,set_data
export PointDuration

load("julia-glplot/KeyedData/Sums.jl")
export SingleSum,PairSum

end

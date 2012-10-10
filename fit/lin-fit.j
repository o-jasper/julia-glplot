#
#  Copyright (C) 10-10-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

type MatrixFitProcess
  xx::Array{Float64,2} #These are sums of x(k)[i]*x(k)[j]
  yx::Array{Float64,2} # and x(k)[i](k)*y(k)[j], with x(k),y(k)
                       # different measurements
  w::Float64 #Total weight
  cnt::Int64 #Number of measurements inputted.
end

function MatrixFitProcess(w::Integer,h::Integer)
  return MatrixFitProcess(fill(float64(0),h,h), fill(float64(0),h,w), 
                          float64(0),int64(0))
end
#Incorporate a piece of information into the linear fit.
# (Just sums stuff to existing values, no allocation)
function incorporate!(mfp::MatrixFitProcess, 
                     x::Vector{Float64},y::Vector{Float64}, weight::Float64)
  mfp.w += weight
  mfp.cnt += 1
  h,w = size(mfp.yx) #It follows from fucking math.
  for i = 1:h
    for j = 1:h 
      mfp.xx[i,j] += x[i]*x[j] #TODO triangle?
    end
    for j = 1:w
      mfp.yx[i,j] += x[i]*y[j]
    end
  end
end
function incorporate!(mfp::MatrixFitProcess, 
                     x::Array{Number,1},y::Array{Number}, weight)
  return incorporate!(mfp,float64(x),float64(y), 
                      float64(weight==nothing ? 1 :weight))
end
# TODO That transpose shouldnt have been needed, and xx and yx should've been
#the other way around.. T(A B^-1) = T(B^-1)T(A) but...
function result(mfp::MatrixFitProcess)
  return transpose(mfp.xx \ mfp.yx)
end

#function error_matrix(mfp::MatrixFitProcess) #TODO
#end

# Matrix fit process as applied to linear fit process.
# Ax+b=y is Mx=y for the last element of x always one.(i am lazy)
type LinFitProcess
  mfp::MatrixFitProcess
end
#Incorporates but modifies it a bit for Ax+b=y fitting.
function incorporate(lfp::LinFitProcess,
                     x::Vector{Float64},y::Vector{Float64}, 
                     weight::Float64)
#Find it strange notation!
  incorporate(lfp.mfp,[mod_x,[float64(1)]],y,weight) 
end

function result(lfp::LinFitProcess)
  w,h = size(lfp.yx)
  A = Array(Float64, w-1,h)
  b = Array(Float64, h)
  m = result(lfp.mfp)
  for j= 1:h
    for i= 1:w-1
      A[i,j] = m[i,j]
    end
    b = m[w,j]
  end
  return (A,b)
end
#function error_matrix(lfp::LinFitProcess) #TODO

type GeneralFitProcess
  funs::Vector{Function}
  mfp::MatrixFitProcess
end

function GeneralFitProcess(funs::Vector{Function},ret_dim::Int64)
  l = length(funs)
  return GeneralFitProcess(funs, MatrixFitProcess(ret_dim*l,l))
end

function incorporate!(gfp::GeneralFitProcess, 
                      x::Vector{Float64},y::Vector{Float64}, weight::Float64)
  incorporate!(gfp.mfp,map(function (f) f(x) end, gfp.funs), y,weight)
end

result(gfp::GeneralFitProcess) = result(gfp.mfp)
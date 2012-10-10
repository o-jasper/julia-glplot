
load("julia-glplot/lin-fit/lin-fit.j")

function gen_random_vec(len)
  v = Array(Float64,len)
  for i = 1:len
    v[i] = rand()
  end
  return v
end

function gen_random_matrix(w,h)
  m = Array(Float64,w,h)
  for i = 1:w 
    for j = 1:h 
      m[i,j] = rand()
    end
  end
  return m
end

function fit_test_feed_random(cnt::Integer,mfp::MatrixFitProcess,
                              m::Array{Float64,2})
  w,h = size(m)
  for n= 1:cnt #Incorporate random results.
    v = gen_random_vec(h)
    incorporate!(mfp, v,m*v,1.0)
  end
  return mfp
end
function fit_test_feed_random(cnt::Integer,m::Array{Float64,2})
  w,h = size(m)
  return fit_test_feed_random(cnt, MatrixFitProcess(w,h), m)
end

#Returns the matrix and the estimated value.
function provide_comparison(cnt,m::Array{Float64,2})
  mfp = fit_test_feed_random(cnt,m)
  return (result(mfp), m, mfp)
end
function provide_comparison(cnt,w,h)
  return provide_comparison(cnt,gen_random_matrix(w,h))
end

#TODO actually test.

#TODO test the Ax + b =y version too.

#TODO test functions within.

#NOTE currenlt just messes about!

load("julia-glplot/util_fun.j")

function test_propagate_flip()
  arr = Array((Float64,Uint8),0)
  c=0
  for i = 1:1000
    propagate_flip(arr,uint8(2), i, 1)
    println("$i $(length(arr)) $arr")
  end  
end

test_propagate_flip()
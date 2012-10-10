
load("julia-glplot/lin-fit/lin-fit.j")
load("julia-glplot/lin-fit/resistor-scan.j")

function random_resistors(cnt)
  array = Array(Float64,cnt)
  for i= 1:cnt
    array[i] = rand()
  end
  return array
end

function total_resistance(resistor_array,involved) 
  r_tot = 0.0
  for i= 1:length(involved)
    assert( involved[i] <= length(resistor_array) )
    r_tot += resistor_array[involved[i]]
  end
  return r_tot
end

#Random combination of integers
function rand_comb (cnt,upto)
  assert( cnt<= upto )
  array = Array(Int16,cnt)
  for i= 1:cnt
    array[i] = randi(upto-i+1)
  end
  sortr!(array)
  for i= 1:cnt
    while contains(array[i+1:],array[i])
      array[i] += 1
    end
  end
  return array
end

function random_test(cnt,times, epsilon)
  resistor_array = random_resistors(cnt)
  
  rss= ResistorSeriesScan(cnt)
  for n= 1:times
    involved = rand_comb(2,cnt)
    incorporate!(rss,involved, total_resistance(resistor_array, involved),
                 1.0)
  end
  resistance_estimate = result(rss)
#Assert the estimates are accurate. TODO implement and use error matrix
  for i=1:length(resistor_array)
    assert(abs(resistor_array[i] - resistance_estimate[i]) < epsilon)
  end
  return (rss, resistor_array)
end

random_test(cnt,times) = random_test(cnt,times,0.01)

random_test(100,100)

load("util/ExpandingArray.j")

function test(cnt::Integer, fr::Integer,to::Integer, arr)
  dict = {int64(0) => int64(0)} #Dictionary on one side.
  function set_i(i,to)
    dict[i] = to
    arr[i]  = to
    if to!=arr[i] || to!=get(dict,i,0)
      println("Immediately afterwards incorrect at $i; 
  dict: $(dict[i]) array: $(arr[i]) set: $to")
    end
  end
#Set randomly
  for n = 1:cnt
    set_i(fr + randi(to-fr), fr - randi(to-fr))
  end
#Check it.
  for i = fr:to
    d = get(dict, i,0)
    a = arr[i]
    if d != a
      println("Afterwards incorrect at $i; dict: $d array: $a")
    end
  end
#Now test iteration.
  for el in arr
    i,v = el
    d = get(dict, i,0)
    if d != v
      println("Iterated yielded incorrect value at $i; dict: $d iter: $v")
    end
  end
end

test(100, -100,100, ExpandingArray(Int64))

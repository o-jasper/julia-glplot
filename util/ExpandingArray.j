# Jasper den Ouden  16-09-2012
#Placed in public domain.

#Expanding arrays with arbitrary setting of indices.

#A reshape that works. (until the julia one starts working again..)
function working_reshape{T}(arr::Array{T,1}, newlen::Integer)
  assert( length(arr) < newlen )
  ret = Array(T, newlen)
  for i = 1:length(arr)
    ret[i] = arr[i]
  end
  return ret
end

type ExpandingArray{T}
  start::Int64
  arr::Array{T,1}
end

ExpandingArray(T, start::Integer) = 
   ExpandingArray(int64(start),Array(T,0))
ExpandingArray(T) = ExpandingArray(T,0)

function ref{T,I<:Integer}(a::ExpandingArray{T}, i::I) 
  j = i - a.start
  return (j < 1 || j>length(a.arr)) ? zero(T) : a.arr[j]
end

function assign{T,I<:Integer}(a::ExpandingArray{T}, to::T, i::I)
  len = length(a.arr)
  if len == 0 #Just start the array there.
    a.start = i-1
    a.arr = [to]
    return a.arr[1]
  end
  j = i - a.start    
  if j<1 #Doesn't go low enough.
    a.arr = working_reshape(a.arr, len - j+1)
    for k = len+1:length(a.arr) #Zero the new elements.
      a.arr[k] = zero(T)
    end
    a.arr = circshift(a.arr, 1-j) #Move the data.
    a.start += j-1 #It starts earlier now.
    j=1
  elseif j>len #Doesn't go high enough.
    a.arr = working_reshape(a.arr, j)
    for k = (len+1):(j-1) #Zero the new elements.
      a.arr[k] = zero(T)
    end
  end
  a.arr[j]= to
  return a.arr[j]
end

min{T}(arr::ExpandingArray{T}) = min(arr.arr)
max{T}(arr::ExpandingArray{T}) = max(arr.arr)

#Iterator without index.
indexless_iter{T}(a::ExpandingArray{T}) = a.arr
#Iterator that doesn't miss any indexes in between.(Here just the regular one)
continuous_iter{T}(a::ExpandingArray{T}) = a
continuous_iter{T}(a::Array{T,1}) = a

#Iterator that also gives you the index.
start{T}(a::ExpandingArray{T}) = int64(1)
done{T}(a::ExpandingArray{T}, i::Int64) = (i >= length(a.arr))
next{T}(a::ExpandingArray{T}, i::Int64) = ((a.start + i,a.arr[i]), i+1)

#TODO hrmm Any way to make ExpandingArray{T,N::Integer} ?
type ExpandingArray2d{T}
  arr::ExpandingArray{ExpandingArray{T}}
end

ref{T,I<:Integer}(a::ExpandingArray2d{T}, i::I,j::I) =
    ref(ref(a.arr, i),j)

assign{T,I<:Integer}(a::ExpandingArray2d{T}, to::T, i::Array{I,1}) =
    set(ref(a.arr, i), j, to)

#TODO code repeat a bit.
function max{T,N<:Number}(f::ExpandingArray2d{T})
  fz = mintype(N)
  for el in f.arr
    fz = max(fz, max(el[2]))
  end
  return fz
end
function min{T,N<:Number}(f::ExpandingArray2d{T})
  tz = maxtype(N)
  for el in f.arr
    tz = min(tz, min(el[2]))
  end
  return tz
end

# TODO iterators, following how the 1d version works.

#  Jasper den Ouden 02-08-2012
# Placed in public domain.

#Depreciated. TODO remove.
isnothing(thing) = isequal(thing,nothing)

#Do stuff with a file open, closing it afterward `file` and `mode` correspond
# to arguments of `open`
macro with_open_file(stream_var,file, mode, body)
  ret = gensym()
  quote $stream_var = open($file,$mode)
    $ret = $body
    close($stream_var)
    return $ret
  end
end

#Find an index that `is` the same.(TODO doesn't already exist?
function find_index{T}(arr::Array{T,1},find::T)
  for i = 1:length(arr)
    if is(arr[i],find)
      return i
    end
  end
  return 0
end

last(v) = v[length(v)]
thelast(v, n::Integer) = v[1+length(v)-n:]
thelast(v, n::Integer) = v[1+length(v)-n:]
butlast(v, n::Integer) = v[1:length(v)-n]
butlast(v) = butlast(v,1)

#'Case of something'.
macro case_of(value, of, clauses) #TODO | or || together clauses.
  assert(is(clauses.head, :block))
  var = gensym()
  function case_fun(clause_1, clauses)
    if isa(clause_1, Expr)
      if is(clause_1.head, :line)
        return isempty(clauses) ? :nothing : case_fun(clauses[1],clauses[2:])
      end
      assert( is(clause_1.head, :if) || is(clause_1.head, symbol(":") ),
              "Improper clause, just `if` and `:` have $clause_1" )
      assert(length(clause_1.args) == 2, 
             "Improper clause ; wrong number of args TODO improveme")
      if is(clause_1.args[1], :default)
        return clause_1.args[2]
      else
        return quote
          if $(Expr(:call, {of, var, clause_1.args[1]}, Any))
            $(clause_1.args[2])
          else
            $(isempty(clauses) ? :nothing :
              case_fun(clauses[1],clauses[2:]))
          end
        end
      end
    else
      isempty(clauses) ? :nothing : case_fun(clauses[1],clauses[2:])
    end
  end
  return (quote
    $var = $value
    $(case_fun(clauses.args[1], clauses.args[2:]))
  end)
end
#Run the clause with the value `isequal` to the given value, clauses are in 
# a `begin ... end` block, each clause may be `if value body... end` or
# `value : body...`
#(use `case_of` for something else than `isequal`) 
macro case(value, clauses)
  :(@case_of $value isequal $clauses)
end    
#Runs first clause to be true. Clauses written identically as `case`
macro cond(clauses)
  :(@case_of true && $clauses)
end
#Written as `cond`, but instead each condition that is true is executed, not
# just the first.
macro each_cond(clauses)
  assert(is(clauses.head, :block), "Not a block.")
  function when_clause (c)
    if !isa(c,Expr)
      return :nothing
    end
    assert( is(c.head, symbol(":")), "Clause Expr not `:`")
    assert( length(c.args)==2, "Clause Expr has wrong number of arguments." )
    :($(c.args[1]) ? $(c.args[2]) : nothing)
  end
  Expr(:block, map(when_clause, clauses.args),Any)
end
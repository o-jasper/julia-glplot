
isnothing(thing) = isequal(thing,nothing)

macro with_open_file(stream_var,file, mode, body)
  ret = gensym()
  quote $stream_var = open($file,$mode)
    $ret = $body
    close($file)
    return $ret
  end
end

function find_index{T}(arr::Array{T,1},find::T)
  for i = 1:length(arr)
    if is(arr[i],find)
      return i
    end
  end
  return 0
end

last(v::Vector) = v[length(v)]

#TODO case like cond..
macro case(value, clauses) #TODO | or || together clauses.
  assert(is(clauses.head, :block))
  var = gensym()
  function case_fun(clause_1, clauses)
    if isa(clause_1, Expr)
      assert( is(clause_1.head, :if) || is(clause_1.head, symbol(":") ) )
      assert(length(clause_1.args) == 2)
      quote
        if isequal($var, $(clause_1.args[1]))
          $(clause_1.args[2])
        else
          $(isempty(clauses) ? :nothing :
                               case_fun(clauses[1],clauses[2:]))

        end
      end
    else
      isempty(clauses) ? :nothing : case_fun(clauses[1],clauses[2:])
    end
  end
  quote
    $var = $value
    $(case_fun(clauses.args[1], clauses.args[2:]))
  end
end

macro cond(clauses) 
  assert(is(clauses.head, :block))
  function cond_fun(clause_1, clauses)
    if isa(clause_1, Expr)
      assert( is(clause_1.head, :if) || is(clause_1.head, symbol(":") ) )
      assert(length(clause_1.args) == 2)
      quote
        if $(clause_1.args[1])
          $(clause_1.args[2])
        else
          $(isempty(clauses) ?  nothing : cond_fun(clauses[1],clauses[2:]))
        end
      end
    else
      isempty(clauses) ? nothing : cond_fun(clauses[1],clauses[2:])
    end
  end
  cond_fun(clauses.args[1], clauses.args[2:])
end

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
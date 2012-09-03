#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

function gl_plot_under{T}(mode::Integer, thing::T, 
                          range::(Number,Number,Number,Number),
                          to::Number, rectangular::Bool)
  function fpos(j::Integer)
    x,y = pos(thing,j,range)
    assert(isa(x,Number) && isa(y,Number))
    return (float64(x),float64(y))
  end
  fx,fy,tx,ty = range
  @with_pushed_matrix begin
    unit_frame_from(range)
    if mode==GL_QUAD_STRIP && !rectangular
      glbegin(mode)
    end
    j::Int64 = 1
    px,py = fpos(j)
    while px<fx && !done(thing,j,range) #Find the start.
      x,y = fpos(j)
      px = x
      py = y
      j+=1
    end #TODO if rectangular, start it up?
    i::Int64 = j
    while !done(thing,i,range) #Plot
      if mode!=GL_QUAD_STRIP || rectangular
        glbegin(mode)
      end
      x,y = fpos(i)
      glvertex(x,y)
      glvertex(x,float64(to))
      if mode!=GL_QUAD_STRIP || rectangular
        glvertex(px,float64(to))
        glvertex(px,rectangular ? y : py)
        glend()
      end
      if x>tx #Until at end.
        break
      end
      px=x
      py=y
      i+=1
    end
    if mode==GL_QUAD_STRIP && !rectangular
      glend()
    end
  end
end
#Variants..(too long..)
gl_plot_under{T}(thing::T, range::(Number,Number,Number,Number), to::Number) =
    gl_plot_under(GL_QUAD_STRIP, thing, range, to, false)
gl_plot_under{T}(thing::T, range::(Number,Number,Number,Number)) =
    gl_plot_under(GL_QUAD_STRIP, thing, range, range[2], false)
gl_plot_above{T}(thing::T, range::(Number,Number,Number,Number)) =
    gl_plot_under(GL_QUAD_STRIP, thing, range, range[4], false)

gl_plot_filled_box{T}(thing::T, range::(Number,Number,Number,Number), 
                      to::Number) =
    gl_plot_under(GL_QUADS, thing, range, to, true)
gl_plot_filled_box{T}(thing::T, range::(Number,Number,Number,Number)) =
    gl_plot_filled_box(thing, range, 0, true)

gl_plot_box{T}(thing::T, range::(Number,Number,Number,Number), to::Number) =
    gl_plot_under(GL_LINE_LOOP, thing, range, to, true)
gl_plot_box{T}(thing::T, range::(Number,Number,Number,Number)) =
    gl_plot_box(thing, range, 0, true)

#Returns the x where the line hits y=0
function exit_pos(sx,sy, ex,ey, range, epsilon)
  fx,fy,tx,ty = range #TODO pretty sure it is wrong.
  
  dx = ex-sx #Fractions of x-passing-options.
  f_fx,f_tx = (abs(dx)>epsilon ? ((sx-fx)/dx, (tx-sx)/dx) : (2,2))
    
  dy = ey-sy #Fractions of y-passing options.
  f_fy,f_ty = (abs(dy)>epsilon ? ((sy-fy)/dy, (ty-sy)/dy) : (2,2))

  g(x) = (x>0 ? x : 2)
  fraction = min(g(f_fx),g(f_tx), g(f_fy),g(f_ty))
  return [sx + dx*fraction, sy + dy*fraction] #Return position.
end

exit_pos(sx,sy,ex,ey, range) = exit_pos(sx,sy,ex,ey, range, 1e-9)

function gl_plot{T}(mode::Integer,thing::T, 
                    range::(Number,Number,Number,Number))
  if done(thing,1,range)
    return
  end
  fx,fy,tx,ty = range
  if fx==tx || tx==ty
    return #TODO this should be some problem.
  end
  inside(x,y) = (x>=fx && y>=fy && x<=tx && y<=ty)
  @with_pushed_matrix begin
    unit_frame_from(range)
    px,py = pos(thing,1,range)
    inside_p::Bool = inside(px,py)
    if inside_p
      glbegin(mode)
      glvertex(px,py)
    end
    i=2
    while !done(thing,i,range)
      x,y = pos(thing,i,range)
      if inside_p
        if inside(x,y) #Staying inside.
          glvertex(x,y)
        else #Going inside, find where.
          glvertex(exit_pos(px,py, x,y, range))
          glend()
          inside_p = false
        end
      else
        if inside(x,y) #Just getting back inside, find where.
          glbegin(mode)
          glvertex(exit_pos(px,py, x,y, range))
          inside_p = true
        end
      end
      px=x
      py=y
      i+=1
    end
    if inside_p #End any current lines.
      glend()
    end
  end
end
#You can pick other things, of course, like GL_TRIANGLE_STRIP if you think 
# it is convex.(TODO.. where? false comment?)
gl_plot{T}(thing::T, range::(Number,Number,Number,Number)) =
    gl_plot(GL_LINE_STRIP, thing::T, range)

#'bar intensity plot'.
function gl_plot_bar_intensity{T}(thing::T, draw_yrange::(Number,Number),
                                  range::(Number,Number,Number,Number),
                                  colors::Array{(Number,Number,Number),1})
  fx,fy, tx,ty = range
  d = (ty-fy)/(length(colors)+1)
  function cur_color(y)
    i = clamp(int(ceil((y-fy)/d)), 1,length(colors))
#    println((i, (y-fy)/d +1- i,y))
    if i == length(colors)
      return colors[i] #==last(colors)
    else
      r,g,b = colors[i] #Interpolate color.
      nr,ng,nb = colors[i+1]
      f = (y-fy)/d +1- i
      return ((1-f)*r + f*nr, (1-f)*g + f*ng, (1-f)*b + f*nb)
    end
  end
  @with_pushed_matrix begin
    draw_fy,draw_ty = draw_yrange
    unit_frame_from(fx,draw_fy, tx,draw_ty)
    @with_primitive GL_QUAD_STRIP begin
      i = 1
      while !done(thing,i,range)
        x,y = pos(thing,i,range)
        glcolor(cur_color(y))
        glvertex(x,0) #TODO more vertices if 'hard edge' desired.
        glvertex(x,1)
        i+=1
      end
    end
  end
end
gl_plot_bar_intensity{T}(thing::T, draw_w::Number,
                      range::(Number,Number,Number,Number),
                      colors::Array{(Number,Number,Number),1}) =
    gl_plot_bar_intensity(thing, (0,draw_w), range,colors)

const grayscale_color = [(0,0,0), (1,1,1)]
#TODO more color themes.

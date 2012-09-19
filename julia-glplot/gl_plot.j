#
#  Copyright (C) 14-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

function gl_plot_under{T}(mode::Integer, thing::T, 
                          range::(Number,Number,Number,Number),
                          to::Number, rectangular::Bool)
  thing = inform_of_range(thing, range)
  fx,fy,tx,ty = range #TODO keep in range on y dir.
  @with_pushed_matrix begin
    unit_frame_from(range)
    if mode==GL_QUAD_STRIP && !rectangular
      glbegin(mode)
    end
    px,py = float64(0),float64(0) #Find first one.
    el,iter_state = next(thing,start(thing)) #_Manually_ using the iterator.
    px,py = el
    while px < fx && !done(thing,iter_state)
      el,iter_state = next(thing,iter_state)
      px,py = el
    end 
    vertex(x,y) = #! #Bit inefficient, clamping all of them.
        glvertex(clamp(x, fx,tx),clamp(y,fy,ty))
    
    while !done(thing,iter_state)
      if mode!=GL_QUAD_STRIP || rectangular
        glbegin(mode)
      end
      (x,y),iter_state = next(thing,iter_state)
      vertex(x,y)
      vertex(x,float64(to))
      if mode!=GL_QUAD_STRIP || rectangular
        vertex(px,float64(to))
        vertex(px, rectangular ? y : py)
        glend()
      end
      if x>tx #Stop at end.
        break
      end
      px,py = (x,y)
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

#TODO pretty sure it is wrong.
#Returns the x where the line hits y=0 
function exit_pos(sx,sy, ex,ey, range, epsilon)
  fx,fy,tx,ty = range 
  
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
  thing = inform_of_range(thing, range)
  fx,fy,tx,ty = range
  if fx==tx || fy==ty
    return #TODO this should be some problem.
  end
  inside(x,y) = (x>=fx && y>=fy && x<=tx && y<=ty)
  @with_pushed_matrix begin
    unit_frame_from(range) #_Manually_ using the iterator.
    (px,py),iter_state = next(thing,start(thing)) 
    inside_p::Bool = inside(px,py)
    if inside_p
      glbegin(mode)
      glvertex(px,py)
    end
    while !done(thing, iter_state)
      (x,y),iter_state = next(thing,iter_state)
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
      px,py = (x,y)
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

function interpolate_color(x, f,t, colors)
  d = (t-f)/(length(colors)+1)
  i = clamp(int(ceil((x-f)/d)), 1,length(colors))
  if i == length(colors)
    return colors[i] #==last(colors)
  else
    r,g,b = colors[i] #Interpolate color.
    nr,ng,nb = colors[i+1]
    frac = (x-f)/d + 1- i
    return ((1-frac)*r + frac*nr, 
            (1-frac)*g + frac*ng, 
            (1-frac)*b + frac*nb)
  end
end

#'bar intensity plot'.
function gl_plot_bar_intensity{T}(thing::T,
     range::(Number,Number,Number,Number),
     colors::Array{(Number,Number,Number), 1}, h::Number)
  thing = inform_of_range(thing, range)
  fx,fy, tx,ty = range
  cur_color(y) = interpolate_color(y, fy,ty, colors)
  @with_pushed_matrix begin
    unit_frame_from(fx,0, tx,1)
    @with_primitive GL_QUAD_STRIP for el in thing
      x,y = el
      glcolor(cur_color(y))
      glvertex(x,0) #TODO more vertices if 'hard edge' desired.
      glvertex(x,1)
    end
  end
end

function gl_plot_bar_intensity{T}(thing::T,
                                  colors::Array{(Number,Number,Number), 1}, 
                                  h::Number)
  gl_plot_bar_intensity(thing, plot_range_of(thing), colors,h)
end
gl_plot_bar_intensity{T}(thing::T,colors::Array{(Number,Number,Number), 1}) =
    gl_plot_bar_intensity(thing,colors, 1)

const grayscale_color = [(0,0,0), (1,1,1)]
#TODO more color themes.

#
#  Copyright (C) 14-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

function gl_plot_under{T}(mode::Integer, thing::T, opts::Options)
    @defaults opts range = plot_range_of(thing)
    @defaults opts to = range[2]
    @defaults opts rectangular = false
    
    iter_state = start(thing)
    if done(thing, iter_state)
        return
    end     
    el,iter_state = next(thing,iter_state) #_Manually_ using the iterator.
    
    thing = inform_of_range(thing, range)
    fx,fy,tx,ty = range #TODO keep in range on y dir.
    @with glpushed() begin
        unit_frame_from(range)
        if mode==GL_QUAD_STRIP && !rectangular
            glbegin(mode)
        end
        px,py = float64(0),float64(0) #Find first one.
        
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
gl_plot_under{T}(mode::Integer,thing::T) = gl_plot_under(mode,thing,@options)

function gl_plot_above{T}(mode::Integer, thing::T, opts::Options)
    @defaults opts range = plot_range_of(thing)
    @set_options opts range = range
    @set_options opts to = range[4]
    gl_plot_under(mode, thing, opts)
end
gl_plot_above{T}(mode,thing::T) = gl_plot_above(mode, thing,@options)

gl_plot_filled_box{T}(thing::T, opts::Options) =
    gl_plot_under(GL_QUADS, thing, opts)
gl_plot_filled_box{T}(thing::T) = gl_plot_filled_box(thing,@options)

gl_plot_box{T}(thing::T, opts::Options) =
    gl_plot_under(GL_LINE_LOOP, thing, opts)
gl_plot_box{T}(thing::T) = gl_plot_box(thing,@options)

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

function gl_plot{T}(mode::Integer,thing::T, opts::Options)
    @defaults opts range = plot_range_of(thing)
    
    iter_state = start(thing)
    if done(thing, iter_state)
        return
    end     
    el,iter_state = next(thing,iter_state) #_Manually_ using the iterator.
    
    thing = inform_of_range(thing, range)
    fx,fy,tx,ty = range
    if fx==tx || fy==ty
        return #TODO this should be some problem.
    end
    inside(x,y) = (x>=fx && y>=fy && x<=tx && y<=ty)
    @with glpushed() begin
        unit_frame_from(range) #_Manually_ using the iterator.
        px,py = el
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

gl_plot{T}(mode::Integer, thing::T) = gl_plot(mode, thing, @options)
gl_plot{T}(thing::T, opts::Options) = gl_plot(GL_LINE_STRIP, thing, opts)
gl_plot{T}(thing::T)                = gl_plot(GL_LINE_STRIP, thing)

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

#TODO more color themes?
const plot_grayscale_color = [(0,0,0), (1,1,1)]

#'bar intensity plot'.
function gl_plot_bar_intensity{T}(thing::T, opts::Options)
  @defaults opts range = plot_range_of(thing)
  @defaults opts colors = plot_grayscale_color
  
  thing = inform_of_range(thing, range)
  fx,fy, tx,ty = range
  if fx==tx || fy == ty
      return
  end
  cur_color(y) = interpolate_color(y, fy,ty, colors)
  @with glpushed() begin
    unit_frame_from(fx,0, tx,1)
    @with glprimitive(GL_QUAD_STRIP) for el in thing
      x,y = el
      glcolor(cur_color(y))
      glvertex(x,0) #TODO more vertices if 'hard edge' desired.
      glvertex(x,1)
    end
  end
end
gl_plot_bar_intensity{T}(thing::T) = gl_plot_bar_intensity(thing, @options)

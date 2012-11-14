#
#  Copyright (C) 14-11-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#Simple line ticks.
function draw_ticks_x(rt::RangeTicks, manner::Function, x_dir::Bool)
    n=0
    for el in rt #TODO hrmm
        n+=1
        if n>2 
            break
        end
    end
    if n<=2 
        return
    end
    @with glpushed() begin
        unit_frame_from(x_dir ? (rt.fr,0, rt.to,1) : (0,rt.fr, 1,rt.to))
        @with glprimitive(GL_LINES) for el in rt
            x,n = el
            size,color = manner(n)
            glcolor(color)
            glvertex(x_dir ? (x,0) : (0,x))
            glvertex(x_dir ? (x,size) : (size,x))
        end
    end
end
function draw_ticks_default(n)
    x = 1/sqrt(max(n,1))
#(x,x) would also work, glcolor works with single number as in grayscale.
    return (x,(x,x,x))
end

draw_ticks_x(rt::RangeTicks) = draw_ticks_x(rt, draw_ticks_default, true)

draw_ticks_y(rt::RangeTicks, manner::Function) = draw_ticks_x(rt, manner, false)
draw_ticks_y(rt::RangeTicks) = draw_ticks_y(rt, draw_ticks_default)

#TODO numbered ticks.
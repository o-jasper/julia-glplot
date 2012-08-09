#
#  Copyright (C) 06-08-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#2d plot that takes up data and keeps it for some duration.
type ContinuousPlot
  duration::Float64
  data::Array{(Float64,Float64),1}

#Smooth scrolling implemented by a 'forward driving force'
# TODO.. not sure about the wisdom thereof.. Does it have good behavior
#  across the range?
  extra_x::Float32 #Extra t to the left.
  stop_time::Float32
  
  min_timestep::Float32
  
  last_time::Float64  #last recording of a time.

  cur_t::Float64   #last pos.
  cur_x::Float64   #last pos.
  cur_v::Float64   #last pos.
  
  ContinuousPlot(duration::Number, extra_x::Number,stop_time::Number) =
      new(float64(duration),Array((Float64,Float64),0), 
          float32(extra_x), float32(stop_time),
          float32(stop_time/100),
          float64(time()), float64(time()),float64(0),float64(1))
end

ContinuousPlot(duration::Number) = 
    ContinuousPlot(duration, duration/20,duration/30)

function timestep(cp::ContinuousPlot, ts::Number)
  last_x = last(cp.data)[1] #TODO more timesteps if needed.
  rx = last_x - cp.cur_x
  cp.cur_v += ((rx + rx^3 + cp.extra_x) - cp.cur_v/cp.stop_time)*ts
  cp.cur_x += cp.cur_v*ts
  cp.cur_t += ts
end

function cur_x(cp::ContinuousPlot, time::Number)
  if isempty(cp.data)
    return float64(0)
  end
  if time - cp.cur_t < cp.min_timestep
    for i = 1:int((time - cp.cur_t)/cp.min_timestep)
      timestep(cp, cp.min_timestep)
    end
  end
  timestep(cp, time - cp.cur_t)
  return cp.cur_x
end

function drop_excess(cp::ContinuousPlot)
  #Keep popping until before the end of duration.
  ret = Array((Float64,Float64),0)
  if length(cp.data)> 0
    last_x = cp.data[length(cp.data)][1]
    while( length(cp.data)>0 &&
           cp.data[1][1] + cp.duration < last_x )
      push(ret, cp.data[1])
      cp.data = cp.data[2:]
    end
  end
  return ret
end

function incorporate(cp::ContinuousPlot, x::Number,y::Number, 
                     drop_excess_p::Bool, time::Number)
  if length(cp.data)>0 #Only increasing times.
    assert(x > cp.data[1][1])
  end
  push(cp.data, (float64(x),float64(y)))
#Get current parameters.
  cp.last_time = time
  
  if drop_excess_p
    return drop_excess(cp)
  end
#  return Array((Float64,Float64),0) #TODO any reason?
end
incorporate(cp::ContinuousPlot, x::Number,y::Number, drop_excess_p::Bool) = 
     incorporate(cp, x,y, drop_excess_p, time())
incorporate(cp::ContinuousPlot, x::Number,y::Number) = 
     incorporate(cp, x,y, true)

#This enables it to use gl_plot, gl_plot_under etc.
pos(cp::ContinuousPlot, i::Integer) = pos(cp.data,i)
done(cp::ContinuousPlot, i::Integer) = done(cp.data,i)

gl_plot(cp::ContinuousPlot, range::(Number,Number,Number,Number)) = 
    gl_plot(cp.data, range)

function plot_range_of(cp::ContinuousPlot, fy::Number,ty::Number,time::Number)
  if length(cp.data)>0
    x_end = cur_x(cp, time) + cp.extra_x
    y_end = cp.data[length(cp.data)][1]
    return (x_end - cp.duration,fy, x_end,ty)
  else
    return (float64(0),float64(0),float64(0),float64(0))
  end
end

gl_plot(cp::ContinuousPlot, fy::Number,ty::Number, time::Number) =
    gl_plot(cp.data, plot_range_of(cp, fy,ty, time))

gl_plot(cp::ContinuousPlot, fy::Number,ty::Number) = 
    gl_plot(cp, fy,ty, time())

#TODO a plot that histograms the input aswel, 
#TODO and a 'averages over different lengths of time' plot.
#Fancier version also histograms stuff.
type ContinuousPlotHist
  cp::ContinuousPlot
  h::Histogram
  arrival::Histogram #Arrival time-difference histogram.
  last_delta::Float64
end

ContinuousPlotHist(duration::Number, fy::Number,ty::Number, n::Integer,
                   arrival_range::Number)=
    ContinuousPlotHist(ContinuousPlot(duration), 
                       Histogram(fy,ty,n),
                       Histogram(0,arrival_range, n), float64(0))

ContinuousPlotHist(duration::Number, fy::Number,ty::Number, n::Integer) =
    ContinuousPlotHist(duration, fy,ty,n, duration/10)
ContinuousPlotHist(duration::Number, fy::Number,ty::Number) =
    ContinuousPlotHist(duration, fy,ty,100)

function incorporate(cpsh::ContinuousPlotHist, x::Number,y::Number, 
                     drop_excess_p::Bool, time::Number)
  incorporate(cpsh.h, y)
  cpsh.last_delta = time - cpsh.cp.last_time #Order matters here.
  incorporate(cpsh.arrival, cpsh.last_delta)
#And finally the continuous plot itself. 
  incorporate(cpsh.cp, x,y, drop_excess_p, time)
end
incorporate(cpsh::ContinuousPlotHist,x::Number,y::Number,drop_excess_p::Bool)=
    incorporate(cpsh, x,y, drop_excess_p,  time())
incorporate(cpsh::ContinuousPlotHist, x::Number,y::Number) =
    incorporate(cpsh, x,y, true)

gl_plot(cpsh::ContinuousPlotHist, range::(Number,Number,Number,Number))=
  gl_plot(cpsh.cp, range)

function gl_plot(cpsh::ContinuousPlotHist)
  (fy,ty) = cpsh.h.s, cpsh.h.s + cpsh.h.d*length(cpsh.h)
  glcolor(0.2,0.2,0.2) #TODO allow user to determine the colors
                       # (..linewidth, etc) throughout
  @with_pushed_matrix begin #And the histogram rotated 90 degrees.
    glrotate(90)
    gltranslate(0,-1)
    gl_plot_filled_box(cpsh.h)
  end
  glcolor(1,0,0)
  gl_plot(cpsh.cp, fy,ty)
end

#TODO arrival distribution (optionally)at different scale with indication.
function gl_plot(cpsh::ContinuousPlotHist, time_distribution_h::Number)
  h = time_distribution_h
  const dot_size = 0.005
  @with_pushed_matrix begin #Time difference distribution plot.
    if h>0
      unit_frame_to(1,0,0,h)
    else
      unit_frame_to(1,1+h,0,1)
    end
    glcolor(0,1,0)
    range = plot_range_of(cpsh.arrival)
    @with_primitive GL_LINES begin
      glvertex(0,0) 
      glvertex(0,1)
      glvertex(1,0)
      glvertex(range[3]/cpsh.cp.duration,1)
    end
    glcolor(0.5,0.5,0.5) 
    gl_plot_filled_box(cpsh.arrival)
    glcolor(1,1,0)
    @with_primitive GL_QUADS begin
      fx,meh = map_to_range(cpsh.last_delta, 0, range)
      fy = 1.5*dot_size/abs(h) - dot_size
      rect_vertices(fx,fy, fx+2*dot_size,fy+2*dot_size/abs(h))
    end
  end
  @with_pushed_matrix begin #Draw regular plot.
    unit_frame_to(0,max(h,0), 1,min(1,1+h))
    gl_plot(cpsh)
    if !isempty(cpsh.cp.data)
      x,y = last(cpsh.cp.data)
      fy,ty = (cpsh.h.s, cpsh.h.s + cpsh.h.d*length(cpsh.h))
      rx,ry = map_to_range(x,y, plot_range_of(cpsh.cp, fy,ty, time()))
      glcolor(1,1,0)
      @with_primitive GL_QUADS begin
        vertices_rect_around(clamp(rx,0,1),clamp(ry,0,1), dot_size)
      end
    end
  end
end
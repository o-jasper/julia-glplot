#
#  Copyright (C) 14-09-2012 Jasper den Ouden.
#
#  This is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

#TODO separate out all the gl stuff.

#2d plot that takes up data and keeps it for some duration.
type ContinuousPlot
    duration::Float64
    data::Vector{Vector{(Float64,Float64)}}
    
    #Smooth scrolling implemented by a 'forward driving force'
    # TODO.. not sure about the wisdom thereof.. Does it have good behavior
    #  across the range?
    extra_x::Float32 #Extra t to the left.
    stop_time::Float32
    
    min_timestep::Float32
    
    last_x::Float64
    last_time::Float64  #last recording of a time.
    
    cur_t::Float64   #last pos.
    cur_x::Float64   #last pos.
    cur_v::Float64   #last pos.
    
    ContinuousPlot(duration::Number, extra_x::Number,stop_time::Number) =
        new(float64(duration),Array(Array((Float64,Float64),0),0), 
            float32(extra_x), float32(stop_time),
            float32(stop_time/100),
            typemin(Float64), float64(time()), 
            float64(time()),float64(0),float64(1))
end

ContinuousPlot(duration::Number) = 
    ContinuousPlot(duration, duration/20,duration/30)

#Moving the view.
function timestep(cp::ContinuousPlot, ts::Number)
  rx = cp.last_x - cp.cur_x
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

#Get rid of all the elements that are outside the shown duration.
function drop_excess(cp::ContinuousPlot)
    ret = Array((Float64,Float64),0)
    for i = 1:length(cp.data)
        data_el = cp.data[i]
        #Keep popping until
        while !isempty(data_el) && #Empty
              data_el[1][1] + cp.duration < cp.last_x #All inside time.
            push(ret, data_el[1])
            cp.data[i] = data_el[2:]
        end
    end
    return ret
end

function incorporate(cp::ContinuousPlot, x::Number,y::Number, i::Integer,
                     opt::Options)
    @defaults opts drop_excess_p=true time = time()
    data = cp.data[i]
    if length(data)>0 #Only increasing times.
        assert(x > data[1][1])
    end
    push(data, (float64(x),float64(y)))
    #Get current parameters.
    cp.last_x = max(cp.last_x, x)
    cp.last_time = time
    
    if drop_excess_p
        return drop_excess(cp)
    end
#  return Array((Float64,Float64),0) #TODO any reason?
end
incorporate(cp::ContinuousPlot, x::Number,y::Number, opt::Options) =
    incorporate(cp, x,y, 1, opt)
incorporate(cp::ContinuousPlot, x::Number,y::Number, i::Integer) =
    incorporate(cp, x,y, i, @options)
incorporate(cp::ContinuousPlot, x::Number,y::Number) =
    incorporate(cp, x,y, 1)

function gl_plot(cp::ContinuousPlot, range::(Number,Number,Number,Number))
    for data_el in cp.data
        #TODO different colors.
        gl_plot(data_el, range) #Plot each one on same area.
    end
end

function range_y(cp::ContinuousPlot)
    fy,ty = typemax(Float64),typemin(Float64)
    for data_el in cp.data
        for el in data
            fy = min(fy,el[2])
            ty = max(ty,el[2])
        end
    end
    return (fy,ty)
end
min_y(x) = range_y()[1]
max_y(x) = range_y()[2]

function plot_range_of(cp::ContinuousPlot, opts::Options)
    @defaults range_y = range_y(cp)  time = time()
    if length(cp.data)>0
        x_end = cur_x(cp, time) + cp.extra_x
        fy,ty = range_y
        return (x_end - cp.duration,fy, x_end,ty)
    else
        return (float64(0),float64(0),float64(0),float64(0))
    end
end

gl_plot(cp::ContinuousPlot, opts::Options) =
    gl_plot(cp, plot_range_of(cp, opts))
gl_plot(cp::ContinuousPlot) = gl_plot(cp::ContinuousPlot, @options)

#Fancy version also histograms stuff. And does a power plot.
type FancyContinuousPlot
    cp::ContinuousPlot
    h::HistogramLinArea
    arrival::HistogramLinArea #Arrival time-difference histogram.
    last_delta::Float64
    pwr::PlotPwr
end

function FancyContinuousPlot(duration::Number, fy::Number,ty::Number, 
                             opts::Options)
    @defaults n=100 arrival_range = duration/10
    @defaults plotpwr_duration=duration/(256*n)
    FancyContinuousPlot(ContinuousPlot(duration), 
                        HistogramLinArea(fy,ty,n),
                        HistogramLinArea(0,arrival_range, n), float64(0),
                        PlotPwr(plotpwr_duration))
end
FancyContinuousPlot(duration::Number, fy::Number,ty::Number) = 
    FancyContinuousPlot(duration, fy,ty,@options)

function incorporate(cpsh::FancyContinuousPlot, x::Number,y::Number,
                     i::Integer, opts::Options)
  incorporate(cpsh.h, y)
  cpsh.last_delta = time - cpsh.cp.last_time #Order matters here.
  incorporate(cpsh.arrival, cpsh.last_delta)
#And finally the continuous plot itself. 
  dropped = incorporate(cpsh.cp, x,y, i, opts)
#Stuff it into the pwr plot.
  for el in dropped
    incorporate(cpsh.pwr, el[1],el[2])
  end
end
incorporate(cpsh::FancyContinuousPlot,x::Number,y::Number, opts::Options)
    incorporate(cpsh, x,y,1,opts)
incorporate(cpsh::FancyContinuousPlot, x::Number,y::Number) =
    incorporate(cpsh, x,y, @options)
incorporate(cpsh::FancyContinuousPlot, x::Number,y::Number, i::Integer) =
    incorporate(cpsh, x,y,i, @options)

#Plot,determining range yourself.
gl_plot(cpsh::FancyContinuousPlot, range::(Number,Number,Number,Number))=
  gl_plot(cpsh.cp, range)

#TODO allow user to determine the colors
# (..linewidth, etc) throughout

#TODO Can this be done more cleanly..
#For instance make them specifically about one thing and have them alter the
# gl matrix accordingly.
#Continuous plot with distribution histogram with current actuality underneath
function gl_plot_basic(cpsh::FancyContinuousPlot, opts::Options)
    @defaults over_hist = true #Whether over an histogram.
    hist = cpsh.h.lin_area
    if under_hist
      glcolor(0.2,0.2,0.2)
      @with glpushed() begin #And the histogram rotated 90 degrees.
        glrotate(90)
        gltranslate(0,-1)
        gl_plot_filled_box(hist)
      end
    end
    glcolor(1,0,0)
    gl_plot(cpsh.cp, hist.f,hist.t)
end

#Continuous plot with histogram and time-distribution histogram.
function gl_plot_time_dist(cpsh::FancyContinuousPlot, h::Number)
  const dot_size = 0.005
  @with glpushed() begin #Time difference distribution plot.
    if h>0
      unit_frame_to(1,0,0,h)
    else
      unit_frame_to(1,1+h,0,1)
    end
    glcolor(0,1,0)
    range = plot_range_of(cpsh.arrival.lin_area)
    @with glprimitive(GL_LINES) begin
      glvertex(0,0) 
      glvertex(0,1)
      glvertex(1,0)
      glvertex(range[3]/cpsh.cp.duration,1)
    end
    glcolor(0.5,0.5,0.5) 
    gl_plot_filled_box(cpsh.arrival.lin_area)
    glcolor(1,1,0)
    @with glprimitive(GL_QUADS) begin
      fx,meh = map_to_range(cpsh.last_delta, 0, range)
      fy = 1.5*dot_size/abs(h) - dot_size
      rect_vertices(fx,fy, fx+2*dot_size,fy+2*dot_size/abs(h))
    end
  end
  unit_frame_to(0,max(h,0), 1,min(1,1+h))
end
 
#Continuous plot with a little space(potentially) for an intensity plot.
function gl_plot_pre_intensity(cpsh::FancyContinuousPlot, w::Number, 
                               colors::Vector)
  @with glpushed() begin
    unit_frame_to(1-w,0, 1,1)
    glrotate(90)
    gltranslate(0,-1)
    gl_plot_bar_intensity(cpsh.h.lin_area, colors)
  end
  unit_frame_to(0,0, 1-w,1)
end
#Note that the data in there increases logithmically.
function gl_plot_pwr(cpsh::FancyContinuousPlot, w::Number)
  @with glpushed() begin
    unit_frame_to(w,0,0,1) #Inverted on x axis!
    hist = cpsh.h.lin_area #TODO this range should be available by function?
    (fy,ty) = (hist.s, hist.s + hist.d*length(hist))
    gl_plot(cpsh.pwr, fy,ty)
  end
  unit_frame_to(w,0,1,1)
end


function gl_plot(cpsh::FancyContinuousPlot, time_distribution_h::Number)
  @with glpushed() begin
    gl_plot_time_dist(cpsh, time_distribution_h)
    gl_plot(cpsh)
  end
end

function gl_plot(cpsh::FancyContinuousPlot, time_distribution_h::Number,
                 intensity_w::Number, colors::Vector)
  @with glpushed() begin
    gl_plot_time_dist(cpsh, time_distribution_h)
    gl_plot_pre_intensity(cpsh, intensity_w, colors)
    gl_plot(cpsh)
  end
end

function gl_plot(cpsh::FancyContinuousPlot, time_distribution_h::Number,
                 intensity_w::Number, colors::Vector, pwr_w::Number)
  @with glpushed() begin
    gl_plot_time_dist(cpsh, time_distribution_h)
    gl_plot_pwr(cpsh, pwr_w) #Below compensates for pwr_w.
    gl_plot_pre_intensity(cpsh, intensity_w/(1-pwr_w), colors) 
    gl_plot(cpsh)
  end
end

#Continuous plot with distribution histogram underneath
function gl_plot(cpsh::FancyContinuousPlot, opts::Options)
  @defaults hist_p = true
  hist = cpsh.h.lin_area
  if hist_p
    glcolor(0.2,0.2,0.2) 
    @with glpushed() begin #And the histogram rotated 90 degrees.
      glrotate(90)
      gltranslate(0,-1)
      gl_plot_filled_box(hist)
    end
  end
  glcolor(1,0,0)
  gl_plot(cpsh.cp, @options range_y = hist.f,hist.t)
end

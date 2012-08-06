
load("get_c.j")

load("autoffi/gl.j")
load("gl_util.j")

load("sdl_bad_utils/init_stuff.j")
load("sdl_bad_utils/sdl_event.j")

load("util/util.j")
load("util/geom.j")

load("histogram.j")

load("plot_able.j")
load("plot_gl.j")
load("plot_histogram_gl.j")

load("continuous_plot_gl.j")

screen_width = 640
screen_height = 640

mouse_xf(i) = i/screen_width
mouse_yf(j) = 1 - j/screen_height
mouse_xf()  = mouse_xf(mouse_x())
mouse_yf()  = mouse_yf(mouse_y())

function run_test()
  init_stuff(screen_width,screen_height)

  next_add_t = time() -1
#  cpsh = ContinuousPlot(20.0)
  cpsh = ContinuousPlotHist(20.0, 0,2)

  start = time()
  prev_time = time()
  while true
  #Add stuff it time to do so.
    if time() > next_add_t #Try make a new path in regular intervals.
      incorporate(cpsh, time()-start, (1+sin(time()))/2 + randexp()/10)
      wait_time = rand()/3
      next_add_t = time() + wait_time
    end
  #Drawing stuff.
    @with_pushed_matrix begin
      unit_frame()
      glcolor(1,1,1)
      gl_plot(cpsh, 0.2)#0,2) #,0.2) 
    end
    finalize_draw()
  #Handle SDL events.
    flush_events()
  end
end

run_this() = run_test()

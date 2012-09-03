
load("load_so.j")
load("get_c.j")

load("autoffi/gl.j")
load("gl_util.j")

load("sdl_bad_utils/init_stuff.j")
load("sdl_bad_utils/sdl_event.j")

#load("util/util.j")
load("util/geom.j")

load("julia-glplot/histogram.j")

load("julia-glplot/plot_able.j")
load("julia-glplot/gl_plot.j")
load("julia-glplot/gl_plot_histogram.j")

load("julia-glplot/util_fun.j")
load("julia-glplot/plot_pwr.j")
load("julia-glplot/gl_plot_pwr.j")

load("julia-glplot/gl_plot_continuous.j")

screen_width = 640
screen_height = 640

mouse_xf(i) = i/screen_width
mouse_yf(j) = 1 - j/screen_height
mouse_xf()  = mouse_xf(mouse_x())
mouse_yf()  = mouse_yf(mouse_y())

function run_test()
  init_stuff(screen_width,screen_height)

  next_add_t = time() -1
  next_print_t = time() -1
#  cpsh = ContinuousPlot(20.0)
  cpsh = FancyContinuousPlot(20.0, 0,2)

  start = time()
  prev_time = time()
  while true
  #Add stuff it time to do so.
    if time() > next_add_t #At random time intervals, add stuff.
      incorporate(cpsh, time()-start, 
                  (1+sin(time()))/2 + randexp()/10 + 2*rand()^10)
      wait_time = rand()/3
      next_add_t = time() + wait_time
    end
    if time() > next_print_t
#      println("$(length(cpsh.pwr.data)) $(cpsh.pwr.data)")
      next_print_t += 1
    end
  #Drawing stuff.
    @with_pushed_matrix begin
      unit_frame()
      unit_frame_to(0.1,0.1, 0.9,0.9)
      glcolor(1,1,1)
      gl_plot(cpsh, 0.2,0.02, grayscale_color, 0.2)
#      gl_plot_bar_intensity(cpsh.h.lin_area, 0.1,grayscale_color)
    end
    finalize_draw()
  #Handle SDL events.
    flush_events()
  end
end

run_test()

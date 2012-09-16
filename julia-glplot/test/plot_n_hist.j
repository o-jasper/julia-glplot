
load("load_so.j")
load("get_c.j")
load("sdl_bad_utils/init_stuff.j")

load("util/util.j")

load("autoffi/gl.j")
load("gl_util.j")

load("sdl_bad_utils/sdl_event.j")

load("util/ExpandingArray.j")
load("julia-glplot/Field.j")

load("julia-glplot/Histogram.j")
#load("julia-glplot/iter_histogram.j")

load("julia-glplot/iter_able.j")
load("julia-glplot/gl_plot.j")
load("julia-glplot/gl_plot_histogram.j")

function run_this()
  screen_width = 640
  screen_height = 640
  init_stuff()

  mx(i) = -1 + 2*i/screen_width
  my(j) = +1 - 2*j/screen_height
  mx()  = mx(mouse_x())
  my()  = my(mouse_y())

  h = Histogram(0.0,10.0, 20)
  for n = 1:2000
    incorporate(h, randexp())
  end
  while true
    @with_pushed_matrix begin
      unit_frame()
      unit_frame_to(0.1,0.1, 0.9,0.9)
      glcolor(0.3,0.3,0.3)
      function sqr(x)
        return x^2
      end
      @with_pushed_matrix gl_plot_under(PlotPath(sqr, -1,1), (-1,0,+1,+1))
      glcolor(1,0,0)
      @with_pushed_matrix gl_plot(PlotPath(sqr), (-1,0,+1,+1))
      
      function circle(a)
        return (cos(6.28*a),sin(6.28*a))
      end
      @with_pushed_matrix gl_plot(PlotPath(circle,0,1), (-1,-1,+1,+1))
      
      glcolor(1,1,1)
      #println(plot_range_of(h))
      @with_pushed_matrix gl_plot(h)#, (0,0, 10,max(h)))
    end
    
    @with_primitive GL_TRIANGLES begin
      glcolor(1.0,0.0,0.0)
      glvertex(mx(),my())
      glvertex(mx()+0.1,my())
      glvertex(mx(),my()+0.1)
    end
    finalize_draw()
    flush_events()
  end
end

run_this()

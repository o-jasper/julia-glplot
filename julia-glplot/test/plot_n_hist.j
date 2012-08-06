
load("get_c.j")
load("sdl_bad_utils/init_stuff.j")

load("autoffi/gl.j")
load("gl_util.j")

load("sdl_bad_utils/sdl_event.j")

load("histogram.j")

load("plot_able.j")
load("plot_gl.j")
load("plot_histogram_gl.j")

function run_this ()
  screen_width = 640
  screen_height = 640
  init_stuff()

  mx(i) = -1 + 2*i/screen_width
  my(j) = 1 - 2*j/screen_height
  mx()  = mx(mouse_x())
  my()  = my(mouse_y())

  h = Histogram(0,10,20)
  for n = 1:2000
    incorporate(h, randexp())
  end
  while true
    @with_pushed_matrix begin
      unit_frame()
      frame_from(0.1,0.1, 0.9,0.9)
      glcolor(0.3,0.3,0.3)
      function sqr(x)
        return x^2
      end
      @with_pushed_matrix gl_plot_under(PlotFun(sqr), (-1,0,+1,+1))
      glcolor(1,0,0)
      @with_pushed_matrix gl_plot(PlotFun(sqr), (-1,0,+1,+1))
      
      function circle(a)
        return (cos(6.28*a),sin(6.28*a))
      end
      @with_pushed_matrix gl_plot(circle, (-1,-1,+1,+1))
      
      glcolor(1,1,1)
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

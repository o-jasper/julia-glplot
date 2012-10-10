
load("util/load_so.j")
load("util/get_c.j")
load("util/util.j")

load("autoffi/gl.j")
load("ffi_extra/gl.j")

load("sdl_bad_utils/sdl_bad_utils.j")

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
    @with glpushed() begin
      unit_frame()
      unit_frame_to(0.1,0.1, 0.9,0.9)
      glcolor(0.3,0.3,0.3)
      function sqr(x)
        return x^2
      end
      @with glpushed() gl_plot_under(PlotPath(sqr, -1,1), (-1,0,+1,+1))
      glcolor(1,0,0)
      @with glpushed() gl_plot(PlotPath(sqr), (-1,0,+1,+1))
      
      function circle(a)
        return (cos(6.28*a),sin(6.28*a))
      end
      @with glpushed() gl_plot(PlotPath(circle,0,1), (-1,-1,+1,+1))
      
      glcolor(1,1,1)
      #println(plot_range_of(h))
      @with glpushed() gl_plot(h)#, (0,0, 10,max(h)))
    end
    
    @with glprimitive(GL_TRIANGLES) begin
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

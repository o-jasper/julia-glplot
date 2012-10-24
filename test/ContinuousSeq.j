
load("options.jl")

load("util/util.j")
load("util/get_c.j")
load("util/geom.j")

load("util/ExpandingArray.j")
load("util/dlmwrite_iter.j")

load("autoffi/gl.j")
load("ffi_extra/gl.j")

load("sdl_bad_utils/sdl_bad_utils.j")

load("julia-glplot/glplot-objects.j")
load("julia-glplot/glplot.j")

import OJasper_Util.*
import ExpandingArrayModule.*
import ExpandingArrayModule.*
import DlmWriteIter.*

import SDL_BadUtils.*
import AutoFFI_GL.*
import FFI_Extra_GL.*

import JuliaGLPlotObjects.*
import JuliaGLPlot.*

function run_this()
  screen_width = 640
  screen_height = 640
  init_stuff()

  mx(i) = -1 + 2*i/screen_width
  my(j) = +1 - 2*j/screen_height
  mx()  = mx(mouse_x())
  my()  = my(mouse_y())

  seq = ContinuousSeq{Symbol}(1)

  next_add_t = time() -1
  while true
    if time() > next_add_t #At random time intervals, add stuff.
      incorporate(seq, :t, time()-start)
      x = (1+sin(time()))/2 + randexp()/10 + 2*rand()^10
      incorporate(seq, :x, x)
      incorporate(seq, :y, x+rand())
      wait_time = rand()/3
      next_add_t = time() + wait_time
    end

    @with glpushed() begin
        gl_plot(seq)
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

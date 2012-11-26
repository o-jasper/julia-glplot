
load("options.jl")

load("util/util.jl")
load("util/get_c.jl")
load("util/geom.jl")

load("util/ExpandingArray.jl")
load("util/dlmwrite_iter.jl")

load("autoffi/gl.jl")
load("ffi_extra/gl.jl")

load("sdl_bad_utils/sdl_bad_utils.jl")

load("julia-glplot/glplot-objects.jl")
load("julia-glplot/glplot.jl")

load("julia-glplot/KeyedData/keyeddata_objs.jl")
load("julia-glplot/KeyedData/keyeddata.jl")
import KeyedData_Objs.*
import KeyedDataMod.*

import OptionsMod.*
import OJasper_Util.*, ExpandingArrayModule.*, DlmWriteIter.*
import SDL_BadUtils.*, AutoFFI_GL.*, FFI_Extra_GL.*
import JuliaGLPlotObjects.*, JuliaGLPlot.*

function run_this()
    screen_width = 640
    screen_height = 640
    init_stuff()
    
    mx(i) = -1 + 2*i/screen_width
    my(j) = +1 - 2*j/screen_height
    mx()  = mx(mouse_x())
    my()  = my(mouse_y())
    
    seq = FancyKeyedData(Symbol, #TODO want that to just be symbol.
                         @options plot_vars=[(:t,:x),(:t,:y)])
    set_data(seq, :t, PointDuration(10))
    
    next_add_t = time() -1
    start_t = time()
    
    dx,dy = 0,0
    function inc()
        t = time()-start_t
        incorporate(seq, :t, t)
        dx += 0.1*(2*rand() - 1) - 0.001*dx
        x = (1+sin(time()))/2
        incorporate(seq, :x, x+dx)
        dy += rand()-0.5
        incorporate(seq, :y, x)
        dy = (2*dy+dx)/3
        wait_time = 0.1*rand()
        next_add_t = time() + wait_time
    end
    while(true)
        if(time() > next_add_t) #At random time intervals, add stuff.
             inc()
        end
        
        @with glpushed() begin
            unit_frame_to(-1,-1, 1,1)
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

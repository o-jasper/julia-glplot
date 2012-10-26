
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
    
    seq = ContinuousSeq(Symbol,0.5)
    
    assign(seq.duration, float64(10), :t)
    
    next_add_t = time() -1
    start_t = time()
    
    function inc()
        t = time()-start_t
        incorporate(seq, :t, t)
        x = (1+sin(time()))/2 + randexp()/10 + 2*rand()^10
        incorporate(seq, :x, x)
        incorporate(seq, :y, x+rand())
        wait_time = rand()/3
        next_add_t = time() + wait_time
    end
    while(true)
        if(time() > next_add_t) #At random time intervals, add stuff.
             inc()
        end
        
        @with glpushed() begin
            unit_frame_to(-1,-1, 1,1)
            @with glpushed() begin
                unit_frame_to(0,0.1, 1,1)
                glcolor(0,1,0)
                gl_plot(seq, (:t,[:x,:y]))
#                glcolor(0,0,1)
#                gl_plot(seq, (:t,:y))
            end
            @with glpushed() begin
                unit_frame_to(0,0, 1,0.1)
                gl_plot_bar_intensity(seq, (:t,[:x,:y]))
            end
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

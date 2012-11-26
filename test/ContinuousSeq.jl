
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
    
    seq = ContinuousSeq(Symbol)
    vr = ViewRange(0.5)
    
    assign(seq.duration, float64(10), :t)
    
    next_add_t = time() -1
    start_t = time()
    
    dx = 0
    dy = 0
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
            timestep_range(vr, plot_range_of(seq, (:t,[:x,:y])))
            range = plot_range_of(vr)
            @with glpushed() begin
                unit_frame_to(0,0.1, 1,1)
                glcolor(0,1,0)
                gl_plot(seq, (:t,[:x,:y, :z]), @options range=range)
#                gl_plot(seq, (:t,:q))
            end
            @with glpushed() begin
                unit_frame_to(0,0, 1,0.1)
                gl_plot_bar_intensity(seq, (:t,[:x,:y]), @options range=range)
            end
            glcolor(1,1,1)
            @with glpushed() begin
                unit_frame_to(0,0.1, 1,0.2)
                draw_ticks_x(RangeTicks(range[1],range[3]))
            end
            @with glpushed() begin
                unit_frame_to(0,0, 0.1,1)
                draw_ticks_y(RangeTicks(range[2],range[4]))
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

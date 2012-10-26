
#Proper defaults on usage with (just)functions.
gl_plot_under(mode::Integer, path_fun::Function, 
              range::(Number,Number,Number,Number), 
              to::Number, rectangular::Bool) =
    gl_plot_under(mode, PlotPath(path_fun), range, to, rectangular)
gl_plot(mode::Integer,path_fun::Function, 
        range::(Number,Number,Number,Number)) =
    gl_plot(mode, PlotPath(path_fun), range)

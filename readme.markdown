
# Opengl plotting
Contains

* Plotting of arrays, functions(anything with a `pos(thing,index)` and
  `done(thing,index)`(`gl_plot` plots them)

* Histograms

* Real time plotter ('oscilloscope style') that (optionally)histograms the
  input and the times between to receivals of time.

It is a bit early in development.

## Depends on
The GL stuff in [parse-c-header](https://github.com/o-jasper/parse-c-header)/[src/julia-src](https://github.com/o-jasper/parse-c-header/tree/master/src/julia-src).

### Usage
To use, edit `~/.juliarc.jl` and add 

    push(LOAD_PATH, "$(julia-glplot)/julia-glplot")

Then things can be loaded with paths originating from that. There is an 
example in `doc/juliarc_part.jl`

#### run.sh and running the examples/test
`run.sh` needs a single argument; the file to be run. That file then `load`s 
the other needed files. Only the files with the `load`s and with a `run_this`
function can be run.

## (maybe)TODO

* How stuff is loaded/run not standard? How do i get this to be according to
  'the best convention' out there?

* expanding', histograms and the logarithmic use thereof
  (prevents prohibitive array sizes which still incorporating *everything*)
  code is there but poorly tested, not sure if it works.

* Real time plotter 'averages over different lengths of time' plot and
  corresponding '2d' histogram.(actually a line of histograms for each)

* better docs, examples.(Well the test are examples.)

* Can help getting data in?

* plotting of 2d arrays and histograms. 

* 3d plots.

* other outputs? (cairo?)

## Copyright
Everything is under GPLv3, license included under `doc/`

## Author
Jasper den Ouden

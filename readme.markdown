
# Opengl plotting
Contains

* Plotting of arrays, functions(anything with a `pos(thing,index)` and
  `done(thing,index)`(`gl_plot` plots them)

* Histograms

* Real time plotter ('oscilloscope style') that (optionally)histograms the
  input and the times between to receivals of time.

It is a bit early in development.

Also contains some utilities i use in `util/`

## Depends on
The GL stuff in [parse-c-header](https://github.com/o-jasper/parse-c-header)/[julia-src](https://github.com/o-jasper/parse-c-header/tree/master/julia-src).

## Usage
To use, edit `~/.juliarc.jl` and add.

    push(LOAD_PATH, "$(julia-glplot)/julia-glplot")

If you didn't forget to run `make` in parse-c-header, things can be loaded
with paths originating from that. There is an example in 
`doc/example_juliarc_part.jl`
(it includes things needed by parse-c-header) The testing files can then be 
run with `julia test/somefile.j` (If all well, not mattering from which
directory)

### Tests
Can be run with `make test_all` and other entries in the makefiles. They 
output into like `test/result/run_list`

    $USER `git status|wc -l` `git log|head -n 1` time `date +%s` ... number of lines in stdout`
	
Inperfect as it is, it gives an indication how well things work. Stdout is 
outputted into `test/result` files aswel, zero lines aught to indicate no 
errors.

## (maybe)TODO

* `plot_able.j` makes things plottable, by adding `done(thing,index)`, 
  and `pos(thing,index)`, much nicer to use the regular iterable stuff.

* How stuff is loaded/run not standard? How do i get this to be according to
  'the best convention' out there?

* expanding', histograms and the logarithmic use thereof
  (prevents prohibitive array sizes which still incorporating *everything*)
  code is there but poorly tested, not sure if it works.

* Real time plotter 'averages over different lengths of time' plot and
  corresponding '2d' histogram.(actually a line of histograms for each)

* better docs, examples.(Well the tests are examples.)

* Can help getting data in?

* plotting of 2d arrays and histograms. 

* 3d plots.

* other outputs? (cairo?)

## Copyright
Everything is under GPLv3, license included under `doc/`

## Author
Jasper den Ouden

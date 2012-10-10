
# Opengl plotting
Contains

* Plotting of arrays, functions(anything with a `pos(thing,index)` and
  `done(thing,index)`(`gl_plot` plots them)

* Histograms(and plotting them), including ones that expand as needed.
  They simply use the expanding array in the utilities included in julia-ffi.
  They use  [parameteric types](http://docs.julialang.org/en/latest/manual/types/#man-parametric-types) so the expanding arrays can easily be switched 
  out with other implementations of expanding arrays.

* Real time plotter ('oscilloscope style') that (optionally)histograms the
  input and the times between to receivals of time.
  (add all sorts of fancy stuff, why not is the idea.)

It is a bit early in development.

## Depends on
TODO update.

The GL stuff in [parse-c-header](https://github.com/o-jasper/parse-c-header)/[julia-src](https://github.com/o-jasper/parse-c-header/tree/master/julia-src).

## Usage
To use, edit `~/.juliarc.jl` and add.

    push(LOAD_PATH, "$(path_to_julia-glplot)) #(Only says julia-glplot once in filename.)

If you didn't forget to run `make` in parse-c-header, things can be loaded
with paths originating from that. There is an example in 
`doc/example_juliarc_part.jl`
(it includes things needed by parse-c-header) The testing files can then be 
run with `julia test/somefile.j` (If all well, not mattering from which
directory)

Currently you have to run it as `julia -L ~/.juliarc.jl` 
TODO use the modules..

### Tests
Can be run with `make test_all` and other entries in the makefiles. They 
output into like `test/result/run_list`

    $USER `git status|wc -l` `git log|head -n 1` time `date +%s` ... number of lines in stdout`
	
Inperfect as it is(bit quickly botched together), it gives an indication how 
well things work. Stdout is outputted into `test/result` files aswel, zero 
lines aught to indicate no errors.

## (maybe)TODO

* Fix out-of-dateness.

* How stuff is loaded/run not standard? How do i get this to be according to
  'the best convention' out there?

* Real time plotter 'averages over different lengths of time' plot and
  corresponding '2d' histogram. What is currently there is a bit too limited.

* better docs, examples.(Well the tests are examples.)
  Example with arduino output.

* plotting of 2d arrays and histograms. 

* 3d plots.

* other outputs? (cairo?)

* Get the linear fitting code to work.

## Copyright
Everything is under GPLv3, license included under `doc/`

## Author
Jasper den Ouden

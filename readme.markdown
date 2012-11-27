
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
The GL stuff in [julia-ffi](https://github.com/o-jasper/julia-ffi).

## Usage
To use, edit `~/.juliarc.jl` if that directory is not already added and 

    push(LOAD_PATH, "$(path_directory_where_project_directory_is))
    
Currently you have to run it as `julia -L ~/.juliarc.jl` 
**TODO** is use the modules, and figure how to load things correctly..

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
	
Inperfect as it is(bit quickly botched together), it gives an indication how 
well things work. Stdout is outputted into `test/result` files aswel, zero 
lines aught to indicate no errors.

## (maybe)TODO

* Update readme.

* Packaging... I *cannot* find how to do it properly, i dont want to load
  stuff, `import` (or now `use`) *should* do it IMO.

* Real time plotter/`KeyedData`
  + 'averages over different lengths of time' 
  + `ContinuousSeq` 'virtual' elements.
  + `KeyedData` 'deltas' as values.(and drawing thereof in `FancyKeyedData`)
  + Real time plot linear fitting.(there is already some linear fitting code)
  + Spectrums.(and drawing thereof)
  + Matrix with correlations.
  
* `FancyKeyedData` as object is the right way? Seems like an elaborate
  set of options, maybe do it that way?

* Waterfall plot. (possibly change real time plotter to do it)
  Note: the real time plotter with many bar plots can do it.
  (but not exactly optimal)

* better docs, examples.(Well the tests are examples.)
  Example with arduino input.

* plotting of 2d arrays and histograms. 

* 3d plots.

* other outputs? (cairo?)

## Copyright
Everything is under GPLv3, license included under `doc/`

## Author
Jasper den Ouden

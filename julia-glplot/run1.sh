#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/jasper/proj/common-lisp/parse-c-header/src/julia-src/sdl_bad_utils
julia -q -L $@ -e 'run_this()'

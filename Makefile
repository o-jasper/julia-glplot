
all:
	echo Currently nothing to be made.\(and don\'t expect anything\); \
	echo There is a test, however.

test_all: test_util test_glplot

test_util:
	cd util/test/;\
	make test
test_glplot:
	cd julia-glplot/test/;\
	make test

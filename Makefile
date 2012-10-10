
all:
	echo Currently nothing to be made.\(and don\'t expect anything\); \
	echo There is a test, however.

test: test_glplot

test_glplot:
	cd julia-glplot/test/;\
	make test

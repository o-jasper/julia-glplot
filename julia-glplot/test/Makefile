
default: test

test:
	echo Testing plotting and histogramming\(rather arbitrarily\); \
	julia plot_n_hist.j > result/plot_n_hist; \
	echo Testing continuously plotting slightly random stuff; \
	julia continuousplot.j > result/continuousplot; \
	cd result; \
	echo $(USER)" `git status |wc -l` `git log |head -n 1` time `date +%s` `wc -l plot_n_hist` `wc -l continuousplot`" > /tmp/sdl_bad_utils_test_tmp;\
	cat run_list >> /tmp/sdl_bad_utils_test_tmp;\
	mv /tmp/sdl_bad_utils_test_tmp run_list; \
	head -n 1 run_list

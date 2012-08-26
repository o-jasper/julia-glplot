
default: test

test:
	echo Testing reading/writing tabbed files.
	julia tabbed_data.j > result/tabbed_data; \
	cd result; \
	echo $(USER)" `git status |wc -l` `git log |head -n 1` time `date +%s` `wc -l tabbed_data`" > /tmp/sdl_bad_utils_test_tmp;\
	cat run_list >> /tmp/sdl_bad_utils_test_tmp;\
	mv /tmp/sdl_bad_utils_test_tmp run_list

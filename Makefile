##
## Command to init new git project from webapp-skeleton.
##--------
init:
	rm Makefile
	mv Makefile.sample Makefile
	rm README.md
	mv README.md.sample README.md

.PHONY : clean

#
#	A simple Makefile for building and testing memcache-ada

GPRBUILD=gprbuild
GPRCLEAN=gprclean
TESTRUNNER=testrunner

all:
	mkdir -p build
	$(GPRBUILD) -p memcache.gpr

test: all
	$(GPRBUILD) -p memcachetest.gpr
	$(GPRBUILD) -p memcachetestxml.gpr
	./$(TESTRUNNER)

clean:
	$(GPRCLEAN) memcache.gpr
	$(GPRCLEAN) memcachetest.gpr
	rm -rf build
	rm -f $(TESTRUNNER)

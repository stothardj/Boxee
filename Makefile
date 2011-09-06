# This will not look quite like a C Makefile
SOURCES=$(wildcard coffee/*.coffee)
.PHONY: clean

js/boxee.js: $(SOURCES)
	./ppp.py coffee/main.coffee > coffee/boxee.coffee
	coffee -c -o js coffee/boxee.coffee

clean:
	rm -f js/*
	rm -f coffee/boxee.coffee
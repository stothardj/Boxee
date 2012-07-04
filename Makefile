# This will not look quite like a C Makefile
SOURCES=$(wildcard coffee/*.coffee)
.PHONY: clean

js/boxee.js: build/boxee.coffee
	coffee -c -o js build/boxee.coffee

build/boxee.coffee: $(SOURCES)
	./ppp.py coffee/main.coffee > build/boxee.coffee

clean:
	rm -f js/*
	rm -f build/boxee.coffee
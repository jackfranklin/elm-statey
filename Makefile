tests:
	cd test && ./node_modules/.bin/elm-test TestRunner.elm

install:
	elm package install && (cd test && elm package install && npm install)

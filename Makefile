COMPILER=cabal
COMPILERGLAGS=

run: server
	dist/build/TitaniumCloud/TitaniumCloud +RTS -N4

server:
	$(COMPILER) $(COMPILERGLAGS) build

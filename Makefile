COMPILER=cabal
COMPILERGLAGS=

run: server
	dist/build/TitaniumCloud/TitaniumCloud +RTS -N2

server:
	$(COMPILER) $(COMPILERGLAGS) build

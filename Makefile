COMPILER=cabal
COMPILERGLAGS=

run: server
	dist/build/TitaniumCloud/TitaniumCloud

server:
	$(COMPILER) $(COMPILERGLAGS) build

COMPILER=cabal

run: server
	dist/build/TitaniumCloud/TitaniumCloud

server:
	$(COMPILER) build

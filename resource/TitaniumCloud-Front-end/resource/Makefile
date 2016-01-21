GHC=ghc
GHCFLAGS=

server:
	$(GHC) $(GHCFLAGS) src/server.hs -o build/server

FindFiles: 
	$(GHC) $(GHCFLAGS) src/FindFiles.hs

clean: 
	rm -rf build/* src/FindFiles.hi src/FindFiles.o

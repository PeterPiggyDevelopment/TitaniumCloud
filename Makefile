GHC=ghc
GHCFLAGS=

FindFiles: 
	$(GHC) $(GHCFLAGS) src/FindFiles.hs

clean: 
	rm -rf build/* src/FindFiles.hi src/FindFiles.o

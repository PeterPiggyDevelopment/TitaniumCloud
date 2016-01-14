GHC=ghc
GHCFLAGS=

FindFiles: 
	$(GHC) $(GHCFLAGS) src/FindFiles.hs

clean: 
	rm -rf FindFiles.hi FindFiles.o

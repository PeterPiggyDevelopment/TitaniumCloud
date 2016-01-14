GHC=ghc
GHCFLAGS=

FindFiles: 
	$(GHC) $(GHCFLAGS) FindFiles.hs

clean: 
	rm -rf FindFiles.hi FindFiles.o

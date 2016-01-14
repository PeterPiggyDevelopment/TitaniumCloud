module FindFiles (getFiles) where

import System.FilePath()
import System.Directory

getFiles :: FilePath -> Bool -> IO [FilePath]
getFiles dir isFilter = doesDirectoryExist dir >>= \e -> if e then
        if isFilter then
            filterHidden <$> getDirectoryContents dir
        else getDirectoryContents dir
    else return []

filterHidden :: [FilePath] -> [FilePath]
filterHidden = filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

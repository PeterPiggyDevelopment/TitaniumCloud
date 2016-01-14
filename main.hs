import System.FilePath()
import System.Directory

main :: IO ()
main = printFiles "."

printFiles :: FilePath -> IO ()
printFiles dir = do 
    isExists <- doesDirectoryExist dir
    if isExists then
        filterLinks <$> (getDirectoryContents dir) >>= printDir
    else print isExists

filterLinks :: [String] -> [String]
filterLinks = filter (not . (`elem` [".", ".."]))

printDir :: [String] -> IO ()
printDir strs = head <$> mapM putStrLn strs

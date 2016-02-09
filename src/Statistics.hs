module Statistics(statisticsThread, writeClickStats, clicksReadPage) where
import Codec.Binary.UTF8.String
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Control.Concurrent.MVar
import Data.Lists(strToAL, strFromAL, hasKeyAL)
import qualified Data.Lists(addToAL)
import System.IO

statisticsThread :: MVar String -> -- MVar for user names to write them to the statistics base
                    MVar [(String, Int)]-> -- MVvar for statistics base
                    IO ()
statisticsThread m store = do 
    name <- takeMVar m
    st <- readMVar store
    swapMVar store (incUsrStats st name) 
    statisticsThread m store

incUsrStats :: [(String, Int)] -> String -> [(String, Int)]
incUsrStats usrs name = if hasKeyAL name usrs
                        then addToAL usrs name 1
                        else Data.Lists.addToAL usrs name 1

addToAL :: [(String, Int)] -> String -> Int -> [(String, Int)]
addToAL ls key val = foldl (replaceInAL key val) [("", 0)] ls

replaceInAL :: String -> Int -> [(String, Int)] -> (String, Int) -> [(String, Int)]
replaceInAL key val [("", 0)] (k, v) = if key == k 
                                       then [(k,v + val)] 
                                       else [(k, v)]
replaceInAL key val ls (k, v) = if key == k 
                                then (k, v + val):ls
                                else (k, v):ls

writeClickStats :: String -> String -> IO ()
writeClickStats page clicks =
    readFile "ClickStats" >>= \db -> putStr (drop (length db) db) >>
     case db of 
        [] -> writeFile "ClickStats" (strFromAL [(page, clicks)])
        "\n" -> writeFile "ClickStats" (strFromAL [(page, clicks)])
        _ -> (\a -> case findPage a page of
            Just (p, c) -> writeFile "ClickStats" (strFromAL 
                 (Data.Lists.addToAL a page (c ++ clicks)))
            Nothing -> writeFile "ClickStats" (strFromAL 
                          (Data.Lists.addToAL a page clicks))) (strToAL db)

clicksReadPage :: String -> IO String
clicksReadPage page = 
    readFile "ClickStats" >>= 
    \db -> case db of 
        [] -> return ""
        "\n" -> return ""
        _ -> (\a -> case findPage a page of
            Just (p, c) -> return c
            Nothing -> return ""
            )(strToAL db)

findPage :: [(String, String)] -> String -> Maybe (String, String)
findPage base page = (\strs -> if not (null strs)
                 then Just (head strs)
                 else Nothing)
                   $ filter (\(p, c) -> page == p) base

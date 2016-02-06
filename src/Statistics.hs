module Statistics(statisticsThread, writeClickStats, clicksReadPage) where
import Codec.Binary.UTF8.String
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Control.Concurrent.MVar
import Data.Lists(strToAL, strFromAL, hasKeyAL, addToAL)

statisticsThread :: MVar String -> -- MVar for user names to write them to the statistics base
                    MVar [(String, Int)]-> -- MVvar for statistics base
                    IO ()
statisticsThread m store = do 
    name <- takeMVar m
    st <- readMVar store
    case name of 
        "+disauthed" -> swapMVar store 
         (("+disauthed" , snd (head st) + 1)
                            :tail st) 
                >> statisticsThread m store
        _ -> swapMVar store (incUsrStats st name) 
            >> statisticsThread m store

incUsrStats :: [(String, Int)] -> String -> [(String, Int)]
incUsrStats usrs name = if hasKeyAL name usrs then
    addToAL usrs name (snd (head 
    (filter (\(n, s) -> n == name) usrs)) + 1)
    else addToAL usrs name 1

writeClickStats :: String -> String -> IO ()
writeClickStats page clicks = 
    readFile "ClickStats" >>= \db ->
     case db of 
        [] -> writeFile "ClickStats" (strFromAL [(page, clicks)])
        "\n" -> writeFile "ClickStats" (strFromAL [(page, clicks)])
        _ -> (\str -> putStr (drop (length str) str)) 
            (show (strToAL db :: [(String, String)])) >> 
            (\a -> case findPage a page of 
            Just (p, c) -> writeFile "ClickStats" (strFromAL 
                 (addToAL a page (c ++ clicks)))
            Nothing -> writeFile "ClickStats" (strFromAL 
                          (addToAL a page clicks))) (strToAL db)

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

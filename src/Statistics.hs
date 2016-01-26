module Statistics(statisticsThread) where
import Control.Concurrent.MVar
import Data.List.Utils(strToAL, hasKeyAL, addToAL)

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

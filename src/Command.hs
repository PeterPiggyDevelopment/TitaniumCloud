module Command(initialHelp, commandLoop) where 

import Control.Concurrent.MVar
import System.Exit(ExitCode(ExitSuccess))
import System.Posix.Process(exitImmediately)
import Data.Lists(strFromAL)
import Data.List(isPrefixOf)
import Debug.Trace(trace)
import DataBase


-- Initial massage
initialHelp = "Hello! This is a TitaniumCloud server!\n" ++
    "If you want to print help, type \"help\""

-- Help massage
help = "If you want to print this help, type \"help\"\n" ++
    "If you want to quit (:()), type \"quit\"\n" ++ 
    "If want to delete DataBase of users, type \"rmdb\"\n" ++
    "If you want to list the Data Base, type \"lsdb\"\n" ++
    "If you want to find user \"namename\" in Data Base, type \"fnusr\"\n" ++
    "If you want to print statistics about users, type \"pst\"\n" ++
    "If you want to print short statistics about users, type \"stst\""

genShortStats :: [(String, Int)] -> (Int, Int)
genShortStats usrs = (first, second)
        where 
          first = Prelude.length (Prelude.tail usrs)
          second = foldl (\n (name, count) -> if name == "+disauthed" then count else n) 0 usrs

commandLoop :: MVar [(String, Int)] ->  IO ()
commandLoop store = do
        procesCommands store
        commandLoop store

procesCommands :: MVar [(String, Int)] -> IO ()
procesCommands store = Prelude.getLine >>= 
        \com -> case com of
             "help" -> Prelude.putStrLn help
             "quit" -> exitImmediately ExitSuccess
             "rmdb" -> Prelude.writeFile "DataBase" "" >> 
                 Prelude.putStrLn "Data Base removed"
             "lsdb" -> Prelude.readFile "DataBase" >>=
                 \db -> Prelude.putStrLn $ "Data Base: " ++ db
             "pst" -> readMVar store >>=
                 \st -> putStrLn ("Statistics since server has been started:" ++ 
                    alToStr st)
             "stst" -> readMVar store >>=
                 \st -> Prelude.putStrLn ("Statistics since server has been started:\n" ++ 
                    "Authenticated users: " ++ show (fst (genShortStats st)) ++ "\n" ++
                    "Not authenticated users: " ++ show (snd (genShortStats st)))
             _ | "find" `isPrefixOf` com -> 
                findUserInDB (drop 5 com, "") False >>=
                     \usr -> case usr of
                         Just (n, p, e) -> if drop 5 com == n 
                             then putStrLn $ n ++ " " ++ p ++ " " ++ e
                             else  putStrLn "False"
                         Nothing -> putStrLn "False"
               | otherwise -> Prelude.putStrLn "Invalid Invalidovich"

alToStr :: [(String, Int)] -> String
alToStr = foldl strCollect ""

strCollect :: String -> (String, Int) -> String
strCollect str (name, num) = str ++ "\n" ++ name ++ ": " ++ show num

module Command(initialHelp, commandLoop) where 

import Control.Concurrent.MVar
import System.Exit(ExitCode(ExitSuccess))
import System.Posix.Process(exitImmediately)
import Data.List.Utils(strFromAL)
import DataBase


-- Initial massage
initialHelp = "Hello! This is a TitaniumCloud server!\n" ++
    "If you want to print help, type \"help\""

-- Help massage
help = "If you want to print this help, type \"help\"\n" ++
    "If you want to exit (:()), type \"exit\"\n" ++ 
    "If want to delete DataBase of users, type \"rmdb\"\n" ++
    "If you want to list the Data Base, type \"lsdb\"\n" ++
    "If you want to find user \"namename\" in Data Base, type \"fnusr\"\n" ++
    "If you want to print statistics about users, type \"pst\"" ++
    "If you want to print short statistics about users, type \"stst\""

genShortStats :: [(String, Int)] -> (Int, Int)
genShortStats usrs = (first, second)
        where 
          first = Prelude.length (Prelude.tail usrs)
          second = snd $ Prelude.last usrs

commandLoop :: MVar [(String, Int)] ->  IO ()
commandLoop store = do
        procesCommands store
        commandLoop store

procesCommands :: MVar [(String, Int)] -> IO ()
procesCommands store = Prelude.getLine >>= 
        \com -> case com of
             "help" -> Prelude.putStrLn help
             "exit" -> exitImmediately ExitSuccess
             "rmdb" -> Prelude.writeFile "DataBase" "" >> 
                 Prelude.putStrLn "Data Base removed"
             "lsdb" -> Prelude.readFile "DataBase" >>=
                 \db -> Prelude.putStrLn $ "Data Base: " ++ db
             "fnusr" -> findUserInDB ("namename", "namename") False >>=
                 \user -> case user of 
                   Just u -> Prelude.putStrLn $ "Data Base has user " ++ fst u
                   Nothing -> Prelude.putStrLn "Data Base has no users whith name \"namename\""
             "pst" -> readMVar store >>=
                 \st -> Prelude.putStrLn ("Statistics since server has been started:\n" ++ 
                    strFromAL st)
             "stst" -> readMVar store >>=
                 \st -> Prelude.putStrLn ("Statistics since server has been started:\n" ++ 
                    "Authenticated users: " ++ show (fst (genShortStats st)) ++ "\n" ++
                    "Not authenticated users: " ++ show (snd (genShortStats st)))
             _ -> Prelude.putStrLn "Invalid Invalidovich"

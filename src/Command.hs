module Command(initialHelp, commandLoop) where 

import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import Control.Monad(sequence, liftM)
import Control.Concurrent(forkIO)
import Control.Concurrent.MVar
import Control.Conditional(ifM)
import System.FilePath(takeExtension)
import System.Directory
import System.Exit(ExitCode(ExitSuccess))
import System.Posix.Process(exitImmediately)
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Text.JSON.String(runGetJSON)
import Data.List(isPrefixOf, isInfixOf, unlines, unwords)
import Data.List.Utils(strFromAL, strToAL, replace, split, hasKeyAL, addToAL)
import Data.List.Split(splitOneOf)
import Numeric(readHex)
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

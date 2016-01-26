module DataBase(findUserInDB, pDB) where 

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


baseAllowedChars = ['a'..'z']++['A'..'Z']++['0'..'9']++"$-_.!*'(),"

pDB :: CharParser () [(String, String)]
pDB = pDBPair `sepBy` char '\n'

pDBPair :: CharParser () (String, String)
pDBPair = many1 pDBChar >>= 
        \name -> optionMaybe (char ':' >> many pDBChar) >>=
        \value -> case value of 
            Just a -> return (name, a)
            Nothing -> return (name, "")

pDBChar :: CharParser () Char
pDBChar = oneOf baseAllowedChars

findUserInDB :: (String, String) -> 
                Bool -> 
                IO (Maybe (String, String))
findUserInDB (name, pass) f = 
    Prelude.readFile "DataBase" >>= \db ->
     case db of 
        [] -> return Nothing
        "\n" -> return Nothing
        _ -> case parse pDB "" (Prelude.tail db) of
         Left e -> return Nothing
         Right a -> return $ 
             (\strs -> if not (Prelude.null strs)
                 then Just (Prelude.head strs)
                 else Nothing)
               $ Prelude.filter (\(n, p) -> if f 
                    then name == n && pass == p
                    else name == n) a


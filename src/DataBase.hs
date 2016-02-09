module DataBase(findUserInDB, signinUser, registerUser, isAuthenticated, getAuthCookies) where 

import Network.HTTP.Server.HtmlForm()
import qualified Data.ByteString as Bin
import qualified Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import System.Directory
import Codec.Binary.UTF8.String
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Data.Lists(strFromAL, strToAL, replace, splitOn, hasKeyAL, addToAL)
import Control.Exception(try,SomeException)
import Control.Monad(liftM)
import HttpSend

pDB :: CharParser () [(String, String, String)]
pDB = pDBThree `sepBy` char '\n'

pDBThree :: CharParser () (String, String, String)
pDBThree = many1 pDBChar >>= 
        \name -> char ':' >> many pDBChar >>=
        \pass -> char ':' >> many pDBChar >>=
        \value -> return (name, pass, value)

pDBChar :: CharParser () Char
pDBChar = oneOf baseAllowedChars

baseAllowedChars = ['a'..'z']++['A'..'Z']++['0'..'9']++"$-_.!*'(),"

findUserInDB :: (String, String) -> 
                Bool -> --strict finding (by password)
                IO (Maybe (String, String, String))
findUserInDB (name, pass) f = 
    readFile "DataBase" >>= \db ->
     case db of 
        [] -> return Nothing
        "\n" -> return Nothing
        _ -> case parse pDB "" (tail db) of
         Left e -> print e >> return Nothing
         Right a -> return ( 
             (\strs -> if not (null strs)
                 then Just (head strs)
                 else Nothing)
               $ filter (\(n, p, e) -> if f 
                    then name == n && pass == p
                    else name == n) a)

first :: (a, b, c) -> a
first (a, _, _) = a

second :: (a, b, c) -> b
second (_, a, _) = a

third :: (a, b, c) -> c
third (_, _, a) = a

signinUser :: [(String, String)] -> IO (Response String)
signinUser a = findUserInDB (snd (head a), snd (last a)) False >>=
        \user -> case user of 
            Just u -> if second u == snd (last a) then
                    try (readFile "web/filesredirect.html") 
                    >>= \mb_txt -> case mb_txt of
                         Right cont -> return $ sendAuth (first u, second u) (primHtml cont)
                         Left e -> return $ sendHtml NotFound (toHtml "OOOOPs")
                               where _hack :: SomeException
                                     _hack = e
                else return $ sendHtml NotAcceptable $ toHtml
                    "Invalid Invalidovich doesn't like your password or username"
            Nothing -> return $ sendAuth (snd (head a), snd (a !! 1))
                    $ toHtml $ "You're not in base, " ++ snd (head a) ++ "!1!"

registerUser :: [(String, String)] -> IO (Response String)
registerUser a = findUserInDB (snd (head a), snd (last a)) False >>=
        \user -> case user of 
            Just u -> return $ sendHtml NotAcceptable $ toHtml
                    "User with the same login is allready exists"
            Nothing -> do
                cont <- readFile "DataBase"
                writeFile ".DataBase.tmp" (take (length cont - 2) cont ++
                    "\n" ++ snd (head a) ++ ":" ++ snd (a !! 1) ++ ":" ++ snd (a !! 2) ++ ":")
                renameFile ".DataBase.tmp" "DataBase"
                createDirectory (snd (head a))
                liftM (sendAuth (snd (head a), snd (a !! 1)) . primHtml) (readFile "web/filesredirect.html")

getAuthCookies :: Request String -> (String, String)
getAuthCookies rq = (first, second)
        where 
          first = if null (map (getCookieValue "name=" . hdrValue) 
                  (retrieveHeaders HdrCookie rq))
                  then []
                  else head $ 
                      map (getCookieValue "name=" . hdrValue) 
                      (retrieveHeaders HdrCookie rq)
          second = if null (map (getCookieValue "pass=" . hdrValue) 
                  (retrieveHeaders HdrCookie rq))
                  then []
                  else head $ 
                      map (getCookieValue "pass=" . hdrValue) 
                      (retrieveHeaders HdrCookie rq)

getCookieValue :: String -> String -> String
getCookieValue val cook = head (Data.Lists.splitOn ";" 
                        (Data.Lists.splitOn val cook !! 1))


isAuthenticated :: Request String -> IO Bool
isAuthenticated rq = if null (fst $ getAuthCookies rq)
                         || null (snd $ getAuthCookies rq)
                 then return False
                 else findUserInDB (getAuthCookies rq) True >>= 
                    \usr -> case usr of
                       Nothing ->  return False
                       Just u ->
                           if second u == snd (getAuthCookies rq) then return True
                                         else return False

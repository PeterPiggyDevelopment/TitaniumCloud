module DataBase(findUserInDB, signinUser, registerUser, isAuthenticated, getAuthCookies) where 

import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import System.Directory
import Codec.Binary.UTF8.String
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Data.Lists(strFromAL, strToAL, replace, splitOn, hasKeyAL, addToAL)
import Control.Exception(try,SomeException)
import HttpSend

pDB :: CharParser () [(String, String, String)]
pDB = pDBThree `sepBy` char '\n'

pDBThree :: CharParser () (String, String, String)
pDBThree = many1 pDBChar >>= 
        \name -> optionMaybe (char ':' >> many pDBChar) >>=
        \pass -> optionMaybe (char ':' >> many pDBChar) >>=
        \value -> case pass of 
            Just p -> case value of 
                Just a -> return (name, p, a)
                Nothing -> return (name, p, "")
            Nothing -> case value of 
                Just a -> return (name, "", a)
                Nothing -> return (name, "" , "")

pDBChar :: CharParser () Char
pDBChar = oneOf baseAllowedChars

baseAllowedChars = ['a'..'z']++['A'..'Z']++['0'..'9']++"$-_.!*'(),"

findUserInDB :: (String, String) -> 
                Bool -> 
                IO (Maybe (String, String, String))
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
               $ Prelude.filter (\(n, p, e) -> if f 
                    then name == n && pass == p
                    else name == n) a

first :: (a, b, c) -> a
first (a, _, _) = a

second :: (a, b, c) -> b
second (_, a, _) = a

third :: (a, b, c) -> c
third (_, _, a) = a

signinUser :: [(String, String)] -> IO (Response String)
signinUser a = findUserInDB (snd (Prelude.head a), snd (Prelude.last a)) False >>=
        \user -> case user of 
            Just u -> if second u == snd (Prelude.last a) then
                    try (Prelude.readFile "web/filesredirect.html") 
                    >>= \mb_txt -> case mb_txt of
                         Right cont -> return $ sendAuth (first u, second u) (primHtml cont)
                         Left e -> return $ sendHtml NotFound (toHtml "OOOOPs")
                               where _hack :: SomeException
                                     _hack = e
                else return $ sendHtml NotAcceptable $ toHtml
                    "Invalid Invalidovich doesn't like your password or username"
            Nothing -> return $ sendAuth (snd (Prelude.head a), snd (a !! 1))
                    $ toHtml $ "You're not in base, " ++ snd (Prelude.head a) ++ "!1!"

registerUser :: [(String, String)] -> IO (Response String)
registerUser a = findUserInDB (snd (Prelude.head a), snd (Prelude.last a)) False >>=
        \user -> case user of 
            Just u -> if second u == snd (Prelude.last a) then
                    try (Prelude.readFile "web/filesredirect.html") 
                    >>= \mb_txt -> case mb_txt of
                         Right cont -> return $ sendAuth (first u, second u) (primHtml cont)
                         Left e -> return $ sendHtml NotFound (toHtml "OOOOPs")
                               where _hack :: SomeException
                                     _hack = e
                else return $ sendHtml NotAcceptable $ toHtml
                    "User with same login is allready exists"
            Nothing -> do
                Prelude.appendFile "DataBase" $ "\n" ++ 
                    snd (Prelude.head a) ++ ":" ++ snd (a !! 1) ++ ":" ++ snd (a !! 2)
                createDirectory $ snd (Prelude.head a)
                return $ sendAuth (snd (Prelude.head a), snd (a !! 1))
                             $ toHtml $ "hello hello, " ++ snd (Prelude.head a) ++ "!1!"

getAuthCookies :: Request String -> (String, String)
getAuthCookies rq = (first, second)
        where 
          first = if Prelude.null (Prelude.map (getCookieValue "name=" . hdrValue) 
                  (retrieveHeaders HdrCookie rq))
                  then []
                  else Prelude.head $ 
                      Prelude.map (getCookieValue "name=" . hdrValue) 
                      (retrieveHeaders HdrCookie rq)
          second = if Prelude.null (Prelude.map (getCookieValue "pass=" . hdrValue) 
                  (retrieveHeaders HdrCookie rq))
                  then []
                  else Prelude.head $ 
                      Prelude.map (getCookieValue "pass=" . hdrValue) 
                      (retrieveHeaders HdrCookie rq)

getCookieValue :: String -> String -> String
getCookieValue val cook = Prelude.head (Data.Lists.splitOn ";" 
                        (Data.Lists.splitOn val cook !! 1))


isAuthenticated :: Request String -> IO Bool
isAuthenticated rq = if Prelude.null (fst $ getAuthCookies rq)
                         || Prelude.null (snd $ getAuthCookies rq)
                 then return False
                 else findUserInDB (getAuthCookies rq) True >>= 
                    \usr -> case usr of
                       Nothing ->  return False
                       Just u ->
                           if second u == snd (getAuthCookies rq) then return True
                                         else return False

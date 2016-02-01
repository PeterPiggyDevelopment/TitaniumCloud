module DataBase(findUserInDB, pDB, registerUser, isAuthenticated, getAuthCookies) where 

import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Data.List.Utils(strFromAL, strToAL, replace, split, hasKeyAL, addToAL)
import HttpSend


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


registerUser :: [(String, String)] -> IO (Response String)
registerUser a = findUserInDB (snd (Prelude.head a), snd (Prelude.last a)) False >>=
        \user -> case user of 
            Just u -> if snd u == snd (Prelude.last a) then
                    return $ sendAuth u
                    $ toHtml $ "You're now authenticated " ++ fst u
                else return $ sendHtml NotAcceptable $ toHtml
                    "User with same login is allready exists"
            Nothing -> do
                Prelude.appendFile "DataBase" $ "\n" ++ 
                    snd (Prelude.head a) ++ ":" ++ snd (a !! 1)
                return $ sendAuth (snd (Prelude.head a), snd (a !! 1))
                             $ toHtml $ "hello hello, " ++ snd (Prelude.head a) ++ "!!!"

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
getCookieValue val cook = Prelude.head (Data.List.Utils.split ";" 
                        (Data.List.Utils.split val cook !! 1))


isAuthenticated :: Request String -> IO Bool
isAuthenticated rq = if Prelude.null (fst $ getAuthCookies rq)
                         && Prelude.null (snd $ getAuthCookies rq)
                 then return False
                 else findUserInDB (getAuthCookies rq) True >>= 
                    \usr -> case usr of
                       Nothing ->  return False
                       Just u ->
                           if snd u == snd (getAuthCookies rq) then return True
                                         else return False

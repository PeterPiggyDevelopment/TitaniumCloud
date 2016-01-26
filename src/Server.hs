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

genShortStats :: [(String, Int)] -> (Int, Int)
genShortStats usrs = (first, second)
        where 
          first = Prelude.length (Prelude.tail usrs)
          second = snd $ Prelude.last usrs

main :: IO ()
main = do 
  Prelude.putStrLn initialHelp
  statmv <- newEmptyMVar 
  statstore <- newMVar [("+disauthed", 0)]
  forkIO (commandLoop statstore)
  forkIO (statisticsThread statmv statstore)
  serverWith defaultConfig {srvPort = 8888} ((\statmvar _ url request -> 
    case rqMethod request of 
        GET -> let ext = takeExtension (url_path url) in 
          case ext of
            ".html" -> ifM (isAuthenticated request) 
                       (putMVar statmvar (fst (getAuthCookies request)) >> 
                       sendResponse Prelude.readFile 
                        (\stat str -> sendHtml stat (primHtml str)) url)
                    (if "files.html" `Data.List.isInfixOf` url_path url then do
                        putMVar statmvar "+disauthed"
                        return $ sendHtml NotFound $
                            thehtml $ concatHtml
                            [ thead noHtml, body $ concatHtml
                               [ toHtml "You don't authorized! If you want to load this page "
                               , toHtml $ exportURL url { url_type = HostRelative }
                               , toHtml ", you must be authorized." 
                               , toHtml $ hotlink "/resource/index.html" (toHtml "Try this instead.")
                               ]
                            ]
                    else putMVar statmvar "+disauthed" >> 
                        sendResponse Prelude.readFile
                        (\stat str -> sendHtml stat (primHtml str)) url)
            ".js" -> sendResponse Prelude.readFile sendScript url
            ".css" -> sendResponse Prelude.readFile sendCss url
            ".png" -> sendResponse Bin.readFile sendPng url
            ".jpg" -> sendResponse Bin.readFile sendJpg url
            ".jpeg" -> sendResponse Bin.readFile sendJpg url
            ".ico" -> sendResponse Bin.readFile sendIco url
            _ -> sendResponse Bin.readFile sendFile url
        POST -> case url_path url of 
            "resource/register" -> 
             case parse pQuery "" $ rqBody request of 
                 Left e -> return $ sendHtml OK 
                     $ toHtml $ "Error on HTTP Line while registering " ++ 
                        "in request body!!! " ++ show e
                 Right a -> case Prelude.length a of 
                    2 -> registerUser a
                    _ -> return $ sendHtml OK 
                     $ toHtml $ "Error on HTTP Line while registering " ++ 
                        "in request body!!! " ++ show a
            _ -> case Prelude.length (url_params url) of
                1 -> case Prelude.head (url_params url) of
                    ("dir", dir) ->
                         liftM (httpSendText OK . Prelude.init . Data.List.unlines) 
                            (getFiles (replace ".." "" dir) True)
                    (p, a) -> do 
                        Prelude.putStrLn $ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (Prelude.length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                        return $ sendHtml BadRequest $ toHtml "Sorry, invalid url parameters"
                2 -> case Prelude.head (url_params url) of
                    ("file", f) -> sendUsrFile ("./" ++
                        replace ".." "" (snd (url_params url !! 1)) ++ "/" ++ f)
                    ("del", file) -> removeFile ( "./" ++ 
                        snd (Prelude.last (url_params url)) ++ file)
                        >> return (respond OK :: Response String)
                    (p, a) -> return $ sendHtml BadRequest 
                        $ toHtml $ "Sorry, invalid url parameters" ++ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (Prelude.length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                3 -> case Prelude.head (url_params url) of
                    ("rename", file) -> renameFile 
                        ("./" ++ snd (Prelude.last (url_params url)) ++ file) 
                        ("./" ++ snd (Prelude.last (url_params url)) ++ 
                            snd (url_params url !! 1)) 
                            >> return (respond OK :: Response String)
                n -> do 
                    Prelude.putStrLn $ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show n
                    return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
        _ -> do 
            Prelude.putStrLn ("Something is coming!" ++ url_path url ++ rqBody request)
            return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
    ) statmv)

statisticsThread :: MVar String -> -- MVar for user names to write them to the statistics base
                    MVar [(String, Int)]-> -- MVvar for statistics base
                    IO ()
statisticsThread m store = do 
    name <- takeMVar m
    st <- readMVar store
    case name of 
        "+disauthed" -> swapMVar store 
         (("+disauthed" , snd (Prelude.head st) + 1)
                            :Prelude.tail st) 
                >> statisticsThread m store
        _ -> swapMVar store (incUsrStats st name) 
            >> statisticsThread m store

incUsrStats :: [(String, Int)] -> String -> [(String, Int)]
incUsrStats usrs name = if hasKeyAL name usrs then
    addToAL usrs name (snd (Prelude.head 
    (Prelude.filter (\(n, s) -> n == name) usrs)) + 1)
    else addToAL usrs name 1

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

debugHeaders :: Request String -> String
debugHeaders rq = strFromAL $ headerToAssociation <$>  rqHeaders rq

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

headerToAssociation :: Header -> (String, String)
headerToAssociation (Header n s) = (show n, s)

parseBodyParams :: Request String -> [(String, String)]
parseBodyParams rq =   strToAL $ Data.List.unwords (splitOneOf "=" 
                         (Data.List.unlines (splitOneOf "&" (rqBody rq))))

pQuery :: CharParser () [(String, String)]
pQuery = pPair `sepBy` char '&'

pPair :: CharParser () (String, String)
pPair = many1 pChar >>= 
        \name -> optionMaybe (char '=' >> many pChar) >>=
        \value -> case value of 
            Just a -> return (name, a)
            Nothing -> return (name, "")

pChar :: CharParser () Char
pChar = oneOf urlBaseChars
     <|> (char '+' >> return ' ')
          <|> pHex

urlBaseChars = ['a'..'z']++['A'..'Z']++['0'..'9']++"$-_.!*'(),"

pHex :: CharParser () Char
pHex = do
          char '%'
          a <- hexDigit
          b <- hexDigit
          let ((d, _):_) = readHex [a,b]
          return . toEnum $ d

pDB :: CharParser () [(String, String)]
pDB = pDBPair `sepBy` char '\n'

pDBPair :: CharParser () (String, String)
pDBPair = many1 pDBChar >>= 
        \name -> optionMaybe (char ':' >> many pDBChar) >>=
        \value -> case value of 
            Just a -> return (name, a)
            Nothing -> return (name, "")

pDBChar :: CharParser () Char
pDBChar = oneOf urlBaseChars

sendResponse ::  (String -> IO a) -> 
                (StatusCode -> a -> Response String) -> 
                URL.URL -> 
                IO (Response String)
sendResponse readf send url = try (readf (url_path url)) >>= \mb_txt -> case mb_txt of
    Right a -> return $ send OK a
    Left e -> return $ sendHtml NotFound $
        thehtml $ concatHtml
          [ thead noHtml, body $ concatHtml
             [ toHtml "I could not find " , toHtml $ exportURL url { url_type = HostRelative }
             , toHtml ", so I made this with XHTML combinators. "
             , toHtml $ hotlink "/resource/index.html" (toHtml "Try this instead.")
             ]
          ]
          where _hack :: SomeException
                _hack = e

sendUsrFile ::  String -> IO (Response String)
sendUsrFile s = try (Bin.readFile s) >>= \mb_txt -> case mb_txt of
    Right a -> return $ sendFile OK a
    Left e -> return $ sendHtml NotFound $
        thehtml $ concatHtml
          [ thead noHtml, body $ concatHtml
             [ toHtml "I could not find " , toHtml s
             , toHtml ", so I made this with XHTML combinators. "
             , toHtml $ hotlink "/resource/index.html" (toHtml "Try this instead.")
             ]
          ]
          where _hack :: SomeException
                _hack = e

sendHtml       :: StatusCode -> Html -> Response String
sendHtml s v    = insertHeader HdrContentType "text/html" $ httpSendText s (renderHtml v)

sendCss       :: StatusCode -> String -> Response String
sendCss s v    = insertHeader HdrContentType "text/css" $ httpSendText s (renderHtml v)

sendScript     :: StatusCode -> String -> Response String
sendScript s v  = insertHeader HdrContentType "application/x-javascript" $ httpSendText s v

sendJson       :: StatusCode -> JSValue -> Response String
sendJson s v    = insertHeader HdrContentType "application/json"
                $ httpSendText s (showJSValue v "")

sendPng     :: StatusCode -> ByteString -> Response String
sendPng s v  = insertHeader HdrContentType "image/png" $ httpSendBinary s v

sendJpg     :: StatusCode -> ByteString -> Response String
sendJpg s v  = insertHeader HdrContentType "image/jpg" $ httpSendBinary s v

sendIco     :: StatusCode -> ByteString -> Response String
sendIco s v  = insertHeader HdrContentType "image/ico" $ httpSendBinary s v

sendAuth :: (String, String) -> Html -> Response String
sendAuth (name, pass) html = insertHeader HdrSetCookie ("name=" ++ name)
                $ insertHeader HdrSetCookie ("pass=" ++ pass)
                $ insertHeader HdrContentType "text/html" 
                $ httpSendText OK (renderHtml html)


sendFile     :: StatusCode -> ByteString -> Response String
sendFile s v  = insertHeader HdrContentType "application/octet-stream" 
                  $ insertHeader (HdrCustom "Content-Disposition") "attachment"
                  $ httpSendBinary s v

--http functions
httpSendText       :: StatusCode -> String -> Response String
httpSendText s v    = insertHeader HdrContentLength (show (Prelude.length txt))
                $ insertHeader HdrContentEncoding "UTF-8"
                $ insertHeader HdrContentEncoding "text/plain"
                $ insertHeader HdrConnection "close" 
                $ (respond s :: Response String) { rspBody = txt }
                  where txt = encodeString v

httpSendBinary       :: StatusCode -> ByteString -> Response String
httpSendBinary s v    = insertHeader HdrConnection "close" 
                $ insertHeader HdrContentLength (show (Bin.length v))
                 (respond s :: Response String)  { rspBody = C.unpack v }

getFiles :: FilePath -> Bool -> IO [FilePath]
getFiles dir isFilter = doesDirectoryExist dir >>= \e -> if e then
        if isFilter then
            filterHidden <$> getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
        else getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
    else return []

slashDirectory :: FilePath -> FilePath -> IO FilePath
slashDirectory dir file = 
        doesDirectoryExist (dir ++ "/" ++ file) >>= \e -> if e then 
            return $ file ++ "//"
        else return file

filterHidden :: [FilePath] -> [FilePath]
filterHidden = Prelude.filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

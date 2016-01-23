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
import Control.Concurrent.Timer(repeatedTimer)
import Control.Concurrent.MVar
import Control.Concurrent.Suspend
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
import Data.List.Utils(strFromAL, strToAL, replace, split)
import Data.List.Split(splitOneOf)
import Numeric(readHex)

help = "Hello! This is a TitaniumCloud server!\nIf you want to print this help, type \"help\"\nIf you want to exit (:()), type \"exit\"\nIf want to delete DataBase of users, type \"rmdb\"\nIf you want to list the Data Base, type \"lsdb\"\nIf you want to find user \"namename\" in Data Base, type \"finduser\""

commandLoop :: IO ()
commandLoop = do
        procesCommands
        commandLoop

procesCommands :: IO ()
procesCommands = Prelude.getLine >>= 
        \com -> case com of
             "rmdb" -> Prelude.writeFile "DataBase" "" >> 
                 Prelude.putStrLn "Data Base removed"
             "exit" -> exitImmediately ExitSuccess
             "help" -> Prelude.putStrLn help
             "lsdb" -> Prelude.readFile "DataBase" >>=
                 \db -> Prelude.putStrLn $ "Data Base: " ++ db
             "finduser" -> findUserInDB "namename" >>=
                 \user -> case user of 
                   Just u -> Prelude.putStrLn $ "Data Base " ++ u
                   Nothing -> Prelude.putStrLn "Data Base doesn't has such user"
             _ -> Prelude.putStrLn "Invalid Invalidovich"

main :: IO ()
main = do 
  Prelude.putStrLn help
  mv <- newEmptyMVar 
  forkIO commandLoop
  repeatedTimer (timerTick mv) (usDelay 1000000)
  serverWith defaultConfig {srvPort = 8888} ((\mvar _ url request -> 
    takeMVar mvar >>
    case rqMethod request of 
        GET -> let ext = takeExtension (url_path url) in 
          case ext of
            ".html" -> ifM (isAuthenticated request) 
                       (sendResponse Prelude.readFile 
                        (\stat str -> sendHtml stat (primHtml str)) url)
                    (if "files.html" `Data.List.isInfixOf` url_path url then do
                        Prelude.putStrLn $ debugHeaders request
                        return $ sendHtml NotFound $
                            thehtml $ concatHtml
                            [ thead noHtml, body $ concatHtml
                               [ toHtml "You don't authorized! If you want to load this page "
                               , toHtml $ exportURL url { url_type = HostRelative }
                               , toHtml ", you must be authorized." 
                               , toHtml $ hotlink "/resource/index.html" (toHtml "Try this instead.")
                               ]
                            ]
                    else sendResponse Prelude.readFile
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
                    (p, a) -> return $ sendHtml BadRequest 
                        $ toHtml $ "Sorry, invalid url parameters" ++ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (Prelude.length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                n -> do 
                    Prelude.putStrLn $ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show n
                    return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
        _ -> do 
            Prelude.putStrLn ("Something is coming!" ++ url_path url ++ rqBody request)
            return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
    ) mv)

timerTick :: MVar () -> IO ()
timerTick m = putMVar m ()

registerUser :: [(String, String)] -> IO (Response String)
registerUser a = findUserInDB (snd (Prelude.head a)) >>=
        \user -> case user of 
            Just u -> return $ sendHtml BadRequest $ toHtml $ "You're allready in base, " ++ u
            Nothing -> do
                Prelude.putStrLn $ "User registered: " ++ show (snd (Prelude.head a))
                Prelude.appendFile "DataBase" $ "\n" ++ 
                    snd (Prelude.head a) ++ ":" ++ snd (a !! 1)
                return $ sendAuth (snd (Prelude.head a)) (snd (a !! 1))
                             $ toHtml $ "hello hello!!!" ++ show a

findUserInDB :: String -> IO (Maybe String)
findUserInDB name = 
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
                           $ Prelude.filter (name ==) (Prelude.map fst a)

isAuthenticated :: Request String -> IO Bool
isAuthenticated rq = findUserInDB (fst (getAuthCookies rq)) >>= 
                    \usr -> case usr of
                       Nothing -> return False
                       Just _ -> return True

debugHeaders :: Request String -> String
debugHeaders rq = strFromAL $ headerToAssociation <$>  rqHeaders rq

getAuthCookies :: Request String -> (String, String)
getAuthCookies rq = (first, second)
        where 
          first = Prelude.head $ 
                  Prelude.map (getCookieValue "name=" . hdrValue) 
                  (retrieveHeaders HdrCookie rq)
          second = Prelude.head $ 
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
sendIco s v  = insertHeader HdrContentType "image/webp" $ httpSendBinary s v

sendAuth :: String -> String -> Html -> Response String
sendAuth name pass html = insertHeader HdrSetCookie ("name=" ++ name)
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
                $ (respond s :: Response String) { rspBody = txt }
                  where txt = encodeString v

httpSendBinary       :: StatusCode -> ByteString -> Response String
httpSendBinary s v    = insertHeader HdrContentLength (show (Bin.length v))
                 (respond s :: Response String)  { rspBody = C.unpack v }

getFiles :: FilePath -> Bool -> IO [FilePath]
getFiles dir isFilter = doesDirectoryExist dir >>= \e -> if e then
        if isFilter then
            filterHidden <$> getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
        else getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
    else return []

slashDirectory :: FilePath -> FilePath -> IO FilePath
slashDirectory dir file = do
        print (dir ++ "/" ++ file)
        doesDirectoryExist (dir ++ "/" ++ file) >>= \e -> if e then 
            return $ file ++ "//"
        else return file

filterHidden :: [FilePath] -> [FilePath]
filterHidden = Prelude.filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

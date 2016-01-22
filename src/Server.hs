import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import Control.Monad(sequence, liftM)
import System.FilePath(takeExtension)
import System.Directory
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Text.JSON.String(runGetJSON)
import Data.List(isPrefixOf, isInfixOf, unlines, unwords)
import Data.List.Utils(strFromAL, strToAL)
import Data.List.Split(splitOneOf)
import Numeric(readHex)

main :: IO ()
main = serverWith defaultConfig {srvPort = 8888} $ \_ url request -> 
    case rqMethod request of 

        GET -> let ext = takeExtension (url_path url) in 
          case ext of
            ".html" | hasAuthCookie request ->
                       sendResponse Prelude.readFile 
                        (\stat str -> sendHtml stat (primHtml str)) url
                    | "files.html" `Data.List.isInfixOf` url_path url -> 
                        return $ sendHtml NotFound $
                        thehtml $ concatHtml
                        [ thead noHtml, body $ concatHtml
                           [ toHtml "You don't authorized! If you want to load this page "
                           , toHtml $ exportURL url { url_type = HostRelative }
                           , toHtml ", you must be authorized." 
                           , toHtml $ hotlink "/resource/index.html" (toHtml "Try this instead.")
                           ]
                        ]
                    | otherwise -> sendResponse Prelude.readFile 
                        (\stat str -> sendHtml stat (primHtml str)) url
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
                     $ toHtml $ "Error on HTTP Line while registering in request body!!! " ++ show e
                 Right a -> return $ sendHtml OK 
                     $ toHtml $ "hello hello!!!" ++ show a
            _ -> case Prelude.length (url_params url) of
                1 -> case Prelude.head (url_params url) of
                    ("dir", d) -> --print $ rqBody request -- Prelude.putStr 
                        liftM (httpSendText OK . Prelude.init . Data.List.unlines) 
                            (getFiles ("./" ++ d) True)
                    (p, a) -> do 
                        Prelude.putStrLn $ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (Prelude.length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                        return $ sendHtml BadRequest $ toHtml "Sorry, invalid url parameters"

                2 -> case Prelude.head (url_params url) of
                    ("file", f) -> sendUsrFile (snd (url_params url !! 1) ++ "/" ++ f)
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

hasAuthCookie :: Request String -> Bool -- TODO: when created database, add a feature that will verificate cookie password
hasAuthCookie rq = Prelude.any (Data.List.isPrefixOf "name=") 
                      (Prelude.map hdrValue (retrieveHeaders HdrCookie rq)) &&
                      Prelude.any (Data.List.isPrefixOf "pass=")
                      (Prelude.map hdrValue (retrieveHeaders HdrCookie rq))

debugHeaders :: Request String -> String
debugHeaders rq = strFromAL $ headerToAssociation <$>  rqHeaders rq

getAuthCookies :: Request String -> (String, String)
getAuthCookies rq = (first, second)
        where 
          first = if Prelude.any (Data.List.isPrefixOf "name=") 
              (Prelude.map hdrValue (retrieveHeaders HdrCookie rq)) then 
                  Prelude.drop 5 $ Prelude.head $ 
                  Prelude.filter (Data.List.isPrefixOf "name=") 
                  (Prelude.map hdrValue (retrieveHeaders HdrCookie rq))
              else []
          second = if Prelude.any (Data.List.isPrefixOf "pass=") 
              (Prelude.map hdrValue (retrieveHeaders HdrCookie rq)) then
                  Prelude.drop 5 $ Prelude.head $ 
                  Prelude.filter (Data.List.isPrefixOf "pass=")
                  (Prelude.map hdrValue (retrieveHeaders HdrCookie rq))
              else []

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
        \value -> return (name, fromMaybe value)

fromMaybe :: Maybe String -> String
fromMaybe (Just a) = a
fromMaybe Nothing = ""

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

sendAuth :: String -> String -> Response String
sendAuth name pass = insertHeader HdrSetCookie ("name=" ++ name)
                $ insertHeader HdrSetCookie ("pass=" ++ pass)
                (respond OK)

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
            filterHidden <$> getDirectoryContents dir >>= \files -> mapM slashDirectory files
        else getDirectoryContents dir >>= \files -> mapM slashDirectory files
    else return []

slashDirectory :: FilePath -> IO FilePath
slashDirectory file = doesDirectoryExist file >>= \e -> if e then 
        return $ file ++ "//"
        else return file

filterHidden :: [FilePath] -> [FilePath]
filterHidden = Prelude.filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

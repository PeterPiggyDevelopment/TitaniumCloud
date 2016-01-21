import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import System.FilePath(takeExtension)
import System.Directory
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types
import Text.JSON.String(runGetJSON)
import Data.List(isPrefixOf, unlines)

main :: IO ()
main = serverWith defaultConfig {srvPort = 8888} $ \_ url request -> 
    case rqMethod request of 

        GET -> let ext = takeExtension (url_path url) in 
          case ext of
            ".html" -> sendResponse Prelude.readFile 
                (\stat str -> sendHtml stat (primHtml str)) url
            ".js" -> sendResponse Prelude.readFile sendScript url
            ".css" -> sendResponse Prelude.readFile sendCss url
            ".png" -> sendResponse Bin.readFile sendPng url
            ".jpg" -> sendResponse Bin.readFile sendJpg url
            ".jpeg" -> sendResponse Bin.readFile sendJpg url
            ".ico" -> sendResponse Bin.readFile sendIco url
            _ -> sendResponse Bin.readFile sendFile url

        POST -> getFiles ("./" ++ url_path url) True >>= (sendFiles . Data.List.unlines)
        _ -> do 
            Prelude.putStrLn ("Something is coming!" ++ url_path url ++ rqBody request)
            return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"

fromMaybe :: String -> Maybe String -> String
fromMaybe no (Just str) = str
fromMaybe no Nothing = no

sendFiles :: String -> IO (Response String)
sendFiles s = return $ httpSendText OK s

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
            filterHidden <$> getDirectoryContents dir
        else getDirectoryContents dir
    else return []

filterHidden :: [FilePath] -> [FilePath]
filterHidden = Prelude.filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

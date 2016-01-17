import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import System.FilePath

main :: IO ()
main = serverWith defaultConfig {srvPort = 8888} $ \_ url request -> 
    case rqMethod request of 

        GET -> let ext = takeExtension (url_path url) in 
          case ext of
            ".html" -> sendRequest Prelude.readFile 
                (\stat str -> sendHtml stat (primHtml str)) url
            ".js" -> sendRequest Prelude.readFile sendScript url
            ".png" -> sendRequest Bin.readFile sendPng url
            ".jpg" -> sendRequest Bin.readFile sendJpg url
            ".jpeg" -> sendRequest Bin.readFile sendJpg url
            ".css" -> sendRequest Prelude.readFile sendCss url
            _ -> return $ sendHtml NotFound $
                        thehtml $ concatHtml
                          [ thead noHtml, body $ concatHtml
                             [ toHtml "I could not find "
                             , toHtml $ exportURL url { url_type = HostRelative }
                             , toHtml ", so I made this with XHTML combinators. "
                             , toHtml $ hotlink "/resource/index.html" (
                              toHtml "Try this instead.")
                             ]
                          ]

        POST -> return $ sendText OK "Super"
        _ -> return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"

sendRequest ::  (String -> IO a) -> 
                (StatusCode -> a -> Response String) -> 
                URL.URL -> 
                IO (Response String)
sendRequest readf send url = try (readf (url_path url)) >>= \mb_txt -> case mb_txt of
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

sendText       :: StatusCode -> String -> Response String
sendText s v    = insertHeader HdrContentLength (show (Prelude.length txt))
                $ insertHeader HdrContentEncoding "UTF-8"
                $ insertHeader HdrContentEncoding "text/plain"
                $ (respond s :: Response String) { rspBody = txt }
                  where txt = encodeString v

sendBinary       :: StatusCode -> ByteString -> Response String
sendBinary s v    = insertHeader HdrContentLength (show (Bin.length v))
                 (respond s :: Response String)  { rspBody = C.unpack v }

sendHtml       :: StatusCode -> Html -> Response String
sendHtml s v    = insertHeader HdrContentType "text/html" $ sendText s (renderHtml v)

sendCss       :: StatusCode -> String -> Response String
sendCss s v    = insertHeader HdrContentType "text/css" $ sendText s (renderHtml v)

sendScript     :: StatusCode -> String -> Response String
sendScript s v  = insertHeader HdrContentType "application/x-javascript" $ sendText s v

sendPng     :: StatusCode -> ByteString -> Response String
sendPng s v  = insertHeader HdrContentType "image/png" $ sendBinary s v

sendJpg     :: StatusCode -> ByteString -> Response String
sendJpg s v  = insertHeader HdrContentType "image/jpg" $ sendBinary s v

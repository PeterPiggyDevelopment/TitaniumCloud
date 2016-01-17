import Network.HTTP.Server.HtmlForm as Form
import Network.HTTP.Server
import Network.HTTP.Server.Logger
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import System.FilePath
--import Text.JSON
--import Text.JSON.String(runGetJSON)
--import Data.List(isPrefixOf)

main :: IO ()
main = serverWith defaultConfig {srvLog = stdLogger, srvPort = 8888} $ \_ url request -> 
    case rqMethod request of 
        GET -> let ext = takeExtension (url_path url) in 
           try (readFile (url_path url)) >>= \mb_txt -> case mb_txt of
                Right a -> return $ case ext of
                    ".html" -> sendHtml OK (primHtml a)
                    ".js" -> sendScript OK a
                    ".css" -> sendCss OK a
                    _ -> sendScript OK a
                Left e -> return $ sendHtml NotFound $
                    thehtml $ concatHtml
                      [ thead noHtml, body $ concatHtml
                         [ toHtml "I could not find "
                         , toHtml $ exportURL url { url_type = HostRelative }
                         , toHtml ", so I made this with XHTML combinators. "
                         , toHtml $ hotlink "/resource/index.html" (
                          toHtml "Try this instead.")
                         ]
                      ]
                      where _hack :: SomeException
                            _hack = e   -- to specify the type

        POST -> return $ sendText OK "Super"
        _ -> return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"

sendText       :: StatusCode -> String -> Response String
sendText s v    = insertHeader HdrContentLength (show (length txt))
                $ insertHeader HdrContentEncoding "UTF-8"
                $ insertHeader HdrContentEncoding "text/plain"
                $ (respond s :: Response String) { rspBody = txt }
                  where txt = encodeString v

sendHtml       :: StatusCode -> Html -> Response String
sendHtml s v    = insertHeader HdrContentType "text/html" $ sendText s (renderHtml v)

sendCss       :: StatusCode -> String -> Response String
sendCss s v    = insertHeader HdrContentType "text/css" $ sendText s (renderHtml v)

sendScript     :: StatusCode -> String -> Response String
sendScript s v  = insertHeader HdrContentType "application/x-javascript" $ sendText s v

module HttpSend where

import Data.ByteString as Bin
import Data.ByteString.Char8 as C
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Codec.Binary.UTF8.String
import Control.Exception(try,SomeException)
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types

sendResponse ::  (String -> IO a) -> 
                (StatusCode -> a -> Response String) -> 
                URL.URL -> 
                String ->
                IO (Response String)
sendResponse readf send url filePath = try (readf filePath) >>= \mb_txt -> case mb_txt of
    Right b -> return $ send OK b
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

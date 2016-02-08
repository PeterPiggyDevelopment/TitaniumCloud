import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin (readFile, writeFile)
import Data.ByteString.Char8 (pack)
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Control.Monad(liftM)
import Control.Exception(catch, SomeException)
import Control.Concurrent(forkIO)
import Control.Concurrent.MVar
import Control.Conditional(ifM)
import System.FilePath(takeExtension)
import System.Directory
import System.IO
import Path (copyDir)
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Text.JSON.String(runGetJSON)
import Data.List(isInfixOf)
import Data.Lists(replace, strToAL, strFromAL, splitOn)
import Data.List.Split(splitOneOf)
import Numeric(readHex)
import Command
import DataBase
import HttpSend
import Statistics

main :: IO ()
main = do 
  putStrLn initialHelp
  statmv <- newEmptyMVar 
  statstore <- newMVar [("+disauthed", 0)]
  forkIO (commandLoop statstore)
  forkIO (statisticsThread statmv statstore)
  serverWith defaultConfig {srvPort = 8888} ((\statmvar _ url request ->
     case rqMethod request of 
        GET -> case url_path url of 
         "resource/register" -> return $ sendHtml BadRequest $ toHtml 
             "You registering with GET request, but you should to register with POST"
         "resource/" -> sendResponse Prelude.readFile
                (\stat str -> sendHtml stat (primHtml str)) url "resource/redirect.html"
         "resource" -> sendResponse Prelude.readFile
                (\stat str -> sendHtml stat (primHtml str)) url "resource/redirect.html"
         "" -> case length (url_params url) of
            1 -> case head (url_params url) of
                ("dir", dir) -> getFiles (replace ".." "" ("./" ++ dir)) True >>=
                        \files -> case unlines files of
                         [] -> return (httpSendText OK "")
                         str ->return (httpSendText OK (init str))
                ("getclicks", f) -> liftM (httpSendText OK) (clicksReadPage f)
                (p, a) -> do 
                    putStrLn $ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show (length (url_params url)) ++ 
                        " fst param: " ++ p ++ ", " ++ a
                    return $ sendHtml BadRequest $ toHtml "Sorry, invalid url parameters"
            2 -> case head (url_params url) of
                ("file", f) -> sendUsrFile ("./" ++
                    replace ".." "" (snd (url_params url !! 1)) ++ "/" ++ f)
                ("pageclicked", f) -> writeClickStats f (snd (last (url_params url))) 
                    >>= (\foo -> return (respond OK :: Response String))
                ("del", file) -> removeFile ("./" ++ 
                    replace ".." "" (snd (last (url_params url))) ++ "/" ++ file)
                    >> return (respond OK :: Response String)
                ("create", file) -> Prelude.writeFile ("./" ++ 
                    replace ".." "" (snd (last (url_params url))) ++ "/" ++ file) ""
                    >> return (respond OK :: Response String)
                ("dircreate", file) -> createDirectory ("./" ++ 
                    replace ".." "" (snd (last (url_params url))) ++ "/" ++ file)
                    >> return (respond OK :: Response String)
                (p, a) -> return $ sendHtml BadRequest 
                    $ toHtml $ "Sorry, invalid url parameters" ++ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show (length (url_params url)) ++ 
                        " fst param: " ++ p ++ ", " ++ a
            3 -> case head (url_params url) of
                ("rename", file) -> renameFile 
                        ("./" ++ snd (last (url_params url))  ++ "/" ++ file) 
                        ("./" ++ replace ".." "" (snd (last (url_params url))) ++ "/" ++
                            snd (url_params url !! 1)) 
                            >> return (respond OK :: Response String)
                (p, a) -> return $ sendHtml BadRequest 
                    $ toHtml $ "Sorry, invalid url parameters" ++ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show (length (url_params url)) ++ 
                        " fst param: " ++ p ++ ", " ++ a
            4 -> case head (url_params url) of
                ("copy", file) -> copyFile 
                    ("./" ++ snd (url_params url !! 1)  ++ "/" ++ file)
                    ("./" ++  snd (last (url_params url))  ++ "/" ++ snd (url_params url !! 2)) 
                    >> return (respond OK :: Response String)
                ("dircopy", file) -> copyDir
                  ("./" ++ snd (url_params url !! 1)  ++ "/" ++ file)
                  ("./" ++  snd (last (url_params url))  ++ "/" ++ snd (url_params url !! 2))
                    >> return (respond OK :: Response String)
                ("move", file) -> renameFile 
                  ("./" ++ snd (url_params url !! 1)  ++ "/" ++ file)
                  ("./" ++  snd (last (url_params url))  ++ "/" ++ snd (url_params url !! 2))
                  >> return (respond OK :: Response String)
                ("dirmove", file) -> renameDirectory
                    ("./" ++ snd (url_params url !! 1)  ++ "/" ++ file)
                    ("./" ++  snd (last (url_params url))  ++ "/" ++ snd (url_params url !! 2))
                     >> return (respond OK :: Response String)
                (p, a) -> return $ sendHtml BadRequest 
                    $ toHtml $ "Sorry, invalid url parameters" ++ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show (length (url_params url)) ++ 
                        " fst param: " ++ p ++ ", " ++ a
            0 -> sendResponse Prelude.readFile
                (\stat str -> sendHtml stat (primHtml str)) url "resource/redirect.html"
            n -> return $ sendHtml BadRequest $ toHtml $ "Sorry, Bad GET Request, " ++ show n ++ "params"
         _ -> let ext = takeExtension (url_path url) in 
              case ext of
                ".html" -> ifM (isAuthenticated request)
                       (putMVar statmvar (fst (getAuthCookies request)) >>
                         sendResponse Prelude.readFile 
                        (\stat str -> (sendHtml stat (primHtml str))) url (url_path url))
                    (if "files.html" `Data.List.isInfixOf` url_path url then do
                        putMVar statmvar "+disauthed"
                        sendResponse Prelude.readFile
                            (\stat str -> sendHtml stat (primHtml str)) url 
                                "resource/authredirect.html"
                    else putMVar statmvar "+disauthed" >> 
                        sendResponse Prelude.readFile
                        (\stat str -> sendHtml stat (primHtml str)) url (url_path url))
                ".js" -> sendResponse Prelude.readFile sendScript url (url_path url)
                ".svg" -> sendResponse Prelude.readFile sendSvg url (url_path url)
                ".css" -> sendResponse Prelude.readFile sendCss url (url_path url)
                ".png" -> sendResponse Bin.readFile sendPng url (url_path url)
                ".jpg" -> sendResponse Bin.readFile sendJpg url (url_path url)
                ".jpeg" -> sendResponse Bin.readFile sendJpg url (url_path url)
                ".ico" -> sendResponse Bin.readFile sendIco url (url_path url)
                _ -> sendResponse Bin.readFile sendFile url (url_path url)

        POST -> case url_path url of 
            "resource/register" -> 
                 case parse pQuery "" $ rqBody request of 
                     Left e -> return $ sendHtml OK 
                         $ toHtml $ "Error on HTTP Line while registering " ++ 
                         "in request body!!! " ++ show e
                     Right a -> case length a of 
                        3 -> registerUser a
                        _ -> return $ sendHtml OK 
                         $ toHtml $ "Error on HTTP Line while registering " ++ 
                         "in request body!!! " ++ show a
            "resource/signin" -> 
                 case parse pQuery "" $ rqBody request of 
                     Left e -> return $ sendHtml OK 
                         $ toHtml $ "Error on HTTP Line while signin " ++ 
                         "in request body!!! " ++ show e
                     Right a -> case length a of 
                        2 -> signinUser a
                        _ -> return $ sendHtml OK 
                         $ toHtml $ "Error on HTTP Line while signin " ++ 
                         "in request body!!! " ++ show a
            "resource/files.html" -> (\filename path ->
                         Bin.writeFile ("./" ++ path ++ "/" ++ filename) 
                         (pack (getFile (rqBody request))))
                         (getFileName (rqBody request)) 
                         (getNameAttr (rqBody request))
                  >> return (respond OK :: Response String)
                   where 
                    getFileName body = head (splitOn "\"" (last (splitOn "filename=\"" body)))
                    getNameAttr body = splitOn "\""  body !! 1
                    getFile body = head (splitOn "\r\n------WebKitFormBoundary" (splitOn "\r\n\r\n"  body !! 1))
            n -> return $ sendHtml BadRequest $ toHtml 
                $ "Error on HTTP addres while getting POST in request url!!! " ++ show n
        _ -> return $ sendHtml BadRequest $ toHtml "Sorry, BadRequest!!"
    ) statmv)

debugHeaders :: Request String -> String
debugHeaders rq = strFromAL $ fmap headerToAssociation (rqHeaders rq)

headerToAssociation :: Header -> (String, String)
headerToAssociation (Header n s) = (show n, s)

parseBodyParams :: Request String -> [(String, String)]
parseBodyParams rq =   strToAL $ unwords (splitOneOf "=" 
                         (unlines (splitOneOf "&" (rqBody rq))))

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

getFiles :: FilePath -> Bool -> IO [FilePath]
getFiles dir isFilter = doesDirectoryExist dir >>= \e -> if e then
        if isFilter then
            fmap filterHidden (getDirectoryContents dir) >>= \files -> mapM (slashDirectory dir) files
        else getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
    else return []

slashDirectory :: FilePath -> FilePath -> IO FilePath
slashDirectory dir file = 
        doesDirectoryExist (dir ++ "/" ++ file) >>= \e -> if e then 
            return $ file ++ "//"
        else return file

filterHidden :: [FilePath] -> [FilePath]
filterHidden = filter dotFilter

dotFilter :: FilePath -> Bool
dotFilter [] = False
dotFilter (x:_) = x /= '.'

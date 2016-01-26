import Network.HTTP.Server.HtmlForm()
import Data.ByteString as Bin (readFile)
import Network.HTTP.Server
import Network.URL as URL
import Text.XHtml
import Control.Monad(liftM)
import Control.Concurrent(forkIO)
import Control.Concurrent.MVar
import Control.Conditional(ifM)
import System.FilePath(takeExtension)
import System.Directory
import Text.JSON(readJSValue, toJSObject, toJSString, showJSValue)
import Text.JSON.Types
import Text.Parsec hiding (try)
import Text.ParserCombinators.Parsec.Char
import Text.JSON.String(runGetJSON)
import Data.List(isInfixOf)
import Data.List.Utils(strFromAL, strToAL, replace, split, hasKeyAL, addToAL)
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
                 Right a -> case length a of 
                    2 -> registerUser a
                    _ -> return $ sendHtml OK 
                     $ toHtml $ "Error on HTTP Line while registering " ++ 
                        "in request body!!! " ++ show a
            _ -> case length (url_params url) of
                1 -> case head (url_params url) of
                    ("dir", dir) ->
                         liftM (httpSendText OK . init . unlines) 
                            (getFiles (replace ".." "" dir) True)
                    (p, a) -> do 
                        putStrLn $ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                        return $ sendHtml BadRequest $ toHtml "Sorry, invalid url parameters"
                2 -> case head (url_params url) of
                    ("file", f) -> sendUsrFile ("./" ++
                        replace ".." "" (snd (url_params url !! 1)) ++ "/" ++ f)
                    ("del", file) -> removeFile ( "./" ++ 
                        snd (last (url_params url)) ++ file)
                        >> return (respond OK :: Response String)
                    (p, a) -> return $ sendHtml BadRequest 
                        $ toHtml $ "Sorry, invalid url parameters" ++ 
                            ":ALERT: Invalid params in url " ++ url_path url ++ 
                            " params nu: " ++ show (length (url_params url)) ++ 
                            " fst param: " ++ p ++ ", " ++ a
                3 -> case head (url_params url) of
                    ("rename", file) -> renameFile 
                        ("./" ++ snd (last (url_params url)) ++ file) 
                        ("./" ++ snd (last (url_params url)) ++ 
                            snd (url_params url !! 1)) 
                            >> return (respond OK :: Response String)
                n -> do 
                    putStrLn $ 
                        ":ALERT: Invalid params in url " ++ url_path url ++ 
                        " params nu: " ++ show n
                    return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
        _ -> do 
            putStrLn ("Something is coming!" ++ url_path url ++ rqBody request)
            return $ sendHtml BadRequest $ toHtml "Sorry, invalid http request"
    ) statmv)

debugHeaders :: Request String -> String
debugHeaders rq = strFromAL $ headerToAssociation <$>  rqHeaders rq

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
            filterHidden <$> getDirectoryContents dir >>= \files -> mapM (slashDirectory dir) files
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

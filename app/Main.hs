{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{- :set -XOverloadedStrings -}
{- :set -XTemplateHaskell -}
{- :set -XQuasiQuotes -}

module Main where

import Codec.Binary.UTF8.String
import Database.HDBC
import Database.HDBC.ODBC
import Data.FileEmbed (embedFile, makeRelativeToProject)
import qualified Data.ByteString as BS
import Data.ByteString.Char8
import Data.ByteString.UTF8
import Data.Char
import qualified Data.Map.Strict as M
import Data.Maybe
import Data.String.Interpolate
import Foreign.C
import Foreign.Ptr
import System.Environment
import Text.Show.Unicode

foreign import ccall "locale.h setlocale" c_setlocale :: CInt -> CString -> IO CString

setCLocale :: IO ()
setCLocale = do
  rc <- withCString "C" $ c_setlocale 0
  return ()
  --when (rc == nullPtr) $ error "setCLocale failed"

connectInfo :: IO (M.Map String String)
connectInfo = do
  dsn <- getEnv "CONN_DSN"
  uid <- getEnv "CONN_UID"
  pwd <- getEnv "CONN_PWD"
  return $ M.fromList [("DSN", dsn), ("UID", uid), ("PWD", pwd)]  

selectSysdateSql :: BS.ByteString
selectSysdateSql = $(makeRelativeToProject "resource/select-sysdate.sql" >>= embedFile)

main :: IO ()
main = do
    setCLocale
    infoMap <- connectInfo
    let 
      dsn = fromJust $ M.lookup "DSN" infoMap
      uid = fromJust $ M.lookup "UID" infoMap
      pwd = fromJust $ M.lookup "PWD" infoMap
    print $ "connect to " ++ dsn ++ " ..."
    print $ [i|DSN=#{dsn};UID=#{uid};PWD=#{pwd}|]
    conn <- connectODBC [i|DSN=#{dsn};UID=#{uid};PWD=#{pwd}|]
    print "connected."
    --Data.ByteString.Char8.putStrLn selectSysdateSql
    --Prelude.putStrLn $ Data.ByteString.UTF8.toString selectSysdateSql
    return ()
    val <- quickQuery' conn "select * from \"M_区分\"" []
--    val <- quickQuery' conn (Data.ByteString.UTF8.toString selectSysdateSql) []
    print val

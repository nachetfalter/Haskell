{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_Art (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [1,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\bin"
libdir     = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\lib\\x86_64-windows-ghc-8.2.2\\Art-1.0-HGJ0R6YsE8Y2hA9o5o9MHI-Art"
dynlibdir  = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\lib\\x86_64-windows-ghc-8.2.2"
datadir    = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\share\\x86_64-windows-ghc-8.2.2\\Art-1.0"
libexecdir = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\libexec\\x86_64-windows-ghc-8.2.2\\Art-1.0"
sysconfdir = "C:\\Users\\wuaiw\\Desktop\\Uni\\18s1\\COMP3141\\Ex02\\Art\\.stack-work\\install\\ccbce92a\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Art_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Art_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Art_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Art_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Art_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Art_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)

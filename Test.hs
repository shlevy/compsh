module Main (main) where

import System ( ExitCode(ExitSuccess, ExitFailure), exitWith, system )
import System.FilePath ( FilePath, takeBaseName )
import IO ( hPutStrLn, stderr)

-- | The path to the binary built by cabal
compshPath :: FilePath
compshPath = "dist/build/compsh/compsh"

-- | Run a command, printing error on bad exit
runCmd :: String -- ^ Prefix for the error message
       -> String -- ^ The command to run
       -> IO ()
runCmd prefix cmd = do
    code <- system cmd
    case code of
      ExitSuccess -> return ()
      ExitFailure x -> hPutStrLn stderr (msg x) >> exitWith code
  where
    msg x = prefix ++ " failed with exit code " ++ (show x)

-- | Compile a cms file to c
compileCms :: FilePath -> IO FilePath
compileCms cms = runCmd prefix cmd >> return outPath
  where
    prefix = "compilation of " ++ cms
    cmd = compshPath ++ " --backend=posix2008 -o " ++ outPath ++ " " ++ cms
    outPath = (takeBaseName cms) ++ ".c"

-- | Compile a c file
compileC :: FilePath -> IO FilePath
compileC c = runCmd prefix cmd >> return outPath
  where
    prefix = "compilation of " ++ c
    cmd = "gcc -o " ++ outPath ++ " " ++ c
    outPath = takeBaseName c

-- | Compile a cms file all the way
compile :: FilePath -> IO FilePath
compile script = compileCms script >>= compileC

-- | Run a test
runTestScript :: FilePath -> IO ()
runTestScript script = compile script >>= runCmd script

main :: IO ()
main = runTestScript "test/single-command/single-command.cms"

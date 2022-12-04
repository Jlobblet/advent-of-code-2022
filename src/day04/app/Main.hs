module Main (main) where

import Lib ( solution )
import Prelude hiding ( getContents )
import Data.Text.Lazy.IO ( getContents )

main :: IO ()
main = getContents >>= (print . solution)

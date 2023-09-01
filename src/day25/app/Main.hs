module Main (main) where

import Data.Text.Lazy.IO (getContents)
import Lib (day25)
import Prelude hiding (getContents)

main :: IO ()
main = getContents >>= print . day25

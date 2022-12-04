import Lib ( solution )

import Data.Text.Lazy ( Text )

sample :: Text
sample = "2-4,6-8\n\
         \2-3,4-5\n\
         \5-7,7-9\n\
         \2-8,3-7\n\
         \6-6,4-6\n\
         \2-6,4-8\n"

main :: IO ()
main = do
    if 2 /= a then error "Part A incorrect" else putStrLn "Part A passed"
    if 4 /= b then error "Part B incorrect" else putStrLn "Part B passed"
    pure ()
    where
        (a, b) = solution sample

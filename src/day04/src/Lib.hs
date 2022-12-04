module Lib
    ( solution
    ) where

import Data.Bifunctor ( Bifunctor, bimap, second )
import Data.Text.Lazy qualified as L
import Data.Text.Lazy ( Text )
import Data.Text.Lazy.Read ( decimal )
import Data.List ( genericLength )

w :: (a -> a -> b) -> a -> b
w f a = f a a

both :: Bifunctor p => (a -> b) -> p a a -> p b b
both = w bimap

solution :: Text -> (Integer, Integer)
solution t = both ($ p) (partA, partB)
    where p = parse t

countWhere :: (a -> Bool) -> [a] -> Integer
countWhere f = genericLength . filter f

partA :: [((Integer, Integer) , (Integer, Integer))] -> Integer
partA = countWhere fullyContained

partB :: [((Integer, Integer) , (Integer, Integer))] -> Integer
partB = countWhere overlaps

overlaps :: ((Integer, Integer) , (Integer, Integer)) -> Bool
overlaps ((l1, r1), (l2, r2))
    | l1 <= r2 && r2 <= r1 = True
    | l2 <= r1 && r1 <= r2 = True
    | otherwise            = False

fullyContained :: ((Integer, Integer), (Integer, Integer)) -> Bool
fullyContained ((l1, r1), (l2, r2))
    | l1 >= l2 && r1 <= r2 = True
    | l2 >= l1 && r2 <= r1 = True
    | otherwise            = False

parse :: Text -> [((Integer, Integer), (Integer, Integer))]
parse = fmap (both toPair . splitOn ",") . L.lines

splitOn :: Text -> Text -> (Text, Text)
splitOn n h = second (L.drop $ L.length n) $ L.breakOn n h

toPair :: Text -> (Integer, Integer)
toPair = both (fromRight . second fst . decimal) . (splitOn "-")

fromRight :: Either a b -> b
fromRight (Left  _) = error "Left given to fromRight"
fromRight (Right b) = b

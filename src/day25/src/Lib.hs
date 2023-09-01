{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( day25,
    snafuParse,
    snafuEncode,
  )
where

import Data.List (unfoldr)
import Data.Text.Lazy as T (Text, foldl, lines, null, pack, reverse)

day25 :: T.Text -> T.Text
day25 = snafuEncode . sum . map snafuParse . filter (not . T.null) . T.lines

snafuParse :: T.Text -> Integer
snafuParse = T.foldl (\a e -> 5 * a + parseChar e) 0
  where
    parseChar '0' = 0
    parseChar '1' = 1
    parseChar '2' = 2
    parseChar '-' = -1
    parseChar '=' = -2
    parseChar _ = undefined

snafuEncode :: Integer -> T.Text
snafuEncode 0 = "0"
snafuEncode i = T.reverse $ T.pack $ unfoldr snafuEncode' i
  where
    snafuEncode' 0 = Nothing
    snafuEncode' j = Just $ case j `divMod` 5 of
      (q, 3) -> ('=', q + 1)
      (q, 4) -> ('-', q + 1)
      (q, r) -> (d r, q)
    d 0 = '0'
    d 1 = '1'
    d 2 = '2'
    d _ = undefined

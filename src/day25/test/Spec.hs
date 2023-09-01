{-# LANGUAGE OverloadedStrings #-}

import Data.Text.Lazy as T (Text, unpack)
import Lib (day25, snafuEncode, snafuParse)
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck as QC

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [unitTests, qcProps]

unitTests :: TestTree
unitTests = testGroup "Unit tests" [exampleInputTests, parseTests, encodeTests]

snafuExamples :: [(T.Text, Integer)]
snafuExamples =
  [ ("0", 0),
    ("1", 1),
    ("2", 2),
    ("1=", 3),
    ("1-", 4),
    ("10", 5),
    ("11", 6),
    ("12", 7),
    ("2=", 8),
    ("2-", 9),
    ("20", 10),
    ("1=0", 15),
    ("1-0", 20),
    ("1=11-2", 2022),
    ("1-0---0", 12345),
    ("1121-1110-1=0", 314159265),
    ("1=-0-2", 1747),
    ("12111", 906),
    ("2=0=", 198),
    ("21", 11),
    ("2=01", 201),
    ("111", 31),
    ("20012", 1257),
    ("112", 32),
    ("1=-1=", 353),
    ("1-12", 107),
    ("122", 37)
  ]

parseTests :: TestTree
parseTests =
  testGroup "Parse tests" $
    uncurry makeTest <$> snafuExamples
  where
    makeTest s i = testCase ("Parse \"" ++ T.unpack s ++ "\"") $ snafuParse s @?= i

encodeTests :: TestTree
encodeTests =
  testGroup "Encode tests" $
    uncurry makeTest <$> snafuExamples
  where
    makeTest s i = testCase ("Encode " ++ show i) $ snafuEncode i @?= s

exampleInputTests :: TestTree
exampleInputTests =
  testCase "Day 25 example" $ day25 exampleInput @?= example
  where
    exampleInput =
      "1=-0-2\n\
      \12111\n\
      \2=0=\n\
      \21\n\
      \2=01\n\
      \111\n\
      \20012\n\
      \112\n\
      \1=-1=\n\
      \1-12\n\
      \12\n\
      \1=\n\
      \122"
    example = "2=-1=0"

qcProps :: TestTree
qcProps =
  testGroup
    "(checked by QuickCheck)"
    [QC.testProperty "snafuParse . snafuEncode == id" snafuRoundtrip]
  where
    snafuRoundtrip (QC.NonNegative i) = (snafuParse . snafuEncode $ i) == i

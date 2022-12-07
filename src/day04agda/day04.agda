{-# OPTIONS --guardedness #-}

module day04 where

open import Data.Bool using (Bool; not; _∧_; _∨_)
open import Data.Char using (Char; _≈ᵇ_)
open import Data.List using (List; _∷_; []; [_]; filterᵇ; length; mapMaybe)
open import Data.Maybe using (Maybe; just; nothing; map; maybe′; zip)
open import Data.Nat using (ℕ; _≤ᵇ_; _<ᵇ_)
open import Data.Nat.Show using (readMaybe; show)
open import Data.Product using (uncurry; _×_; _,_)
open import Data.String using (String; lines; wordsByᵇ; _++_)
open import Data.Unit.Polymorphic using (⊤)
open import Function using (_$_; _∘_; _∘₂_)
open import IO using (IO; Main; pure; putStrLn)
open import IO.Finite using (readFile)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import System.Environment using (getArgs)

--------------------------------------------------------------------------------
-- Parsing

both : ∀ {a b} {A : Set a} {B : Set b} → (A → B) → A × A → B × B
both f (x , y) = (f x) , (f y)

split2ᵇ : (Char → Bool) → String → Maybe (String × String)
split2ᵇ f s with wordsByᵇ f s
... | a ∷ b ∷ [] = just (a , b)
... | _ = nothing

parse : String → List ((ℕ × ℕ) × (ℕ × ℕ))
parse = (mapMaybe parseLine) ∘ lines
  where
    parse2 :
      ∀ {a} {A : Set a}
      → Char
      → (String → Maybe A)
      → String
      → Maybe (A × A)
    parse2 c p s = split2ᵇ (_≈ᵇ c) s >>= (uncurry zip ∘ (both p))
      where
        open import Data.Maybe using (_>>=_)
    parsePair : String → Maybe (ℕ × ℕ)
    parsePair  = parse2 '-' (readMaybe 10)

    parseLine : String → Maybe ((ℕ × ℕ) × (ℕ × ℕ))
    parseLine = parse2 ',' parsePair

    -- Lemmas

    parsePair-lemma : (parsePair "1-2") ≡ just (1 , 2)
    parsePair-lemma = refl

    parseLine-lemma : (parseLine "1-2,3-4") ≡ just ((1 , 2) , (3 , 4))
    parseLine-lemma = refl

    parse2-lemma-1 :
      (parse2 '\n' just "1-2,3-4\n5-6,7-8")
      ≡ just ("1-2,3-4" , "5-6,7-8")
    parse2-lemma-1 = refl

    parse2-lemma-2 :
      (parse2 '\n' parseLine "1-2,3-4\n5-6,7-8")
      ≡ just (((1 , 2) , (3 , 4)) , ((5 , 6) , (7 , 8)))
    parse2-lemma-2 = refl

--------------------------------------------------------------------------------
-- Problem

_≥ᵇ_ : ℕ → ℕ → Bool
m ≥ᵇ n = not (m <ᵇ n)

one-contains-other : ℕ × ℕ → ℕ × ℕ → Bool
one-contains-other m n = (m ⊆ᵇ n) ∨ (n ⊆ᵇ m)
  where
    _⊆ᵇ_ : ℕ × ℕ → ℕ × ℕ → Bool
    (l₁ , r₁) ⊆ᵇ (l₂ , r₂) = (l₂ ≤ᵇ l₁) ∧ (r₂ ≥ᵇ r₁)

has-overlap : ℕ × ℕ → ℕ × ℕ → Bool
has-overlap m n = (m overlaps n) ∨ (n overlaps m)
  where
    _overlaps_ : ℕ × ℕ → ℕ × ℕ → Bool
    (l₁ , r₁) overlaps (_ , r₂) = (l₁ ≤ᵇ r₂) ∧ (r₂ ≤ᵇ r₁)

part : (ℕ × ℕ → ℕ × ℕ → Bool) → List ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ
part f = length ∘ filterᵇ (uncurry f)

part₁ : List ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ
part₁ = part one-contains-other

part₂ : List ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ
part₂ = part has-overlap

--------------------------------------------------------------------------------
-- Main

module _ where
  open import IO using (run; _>>=_; _>>_)
  main : Main
  main = run $ do
    args ← getArgs
    process args

    where
        process : List String → IO ⊤
        process [] = putStrLn "No input provided"
        process (fp ∷ _) = do
          contents ← readFile fp
          let input = parse contents
          putStrLn ∘ show ∘ part₁ $ input
          putStrLn ∘ show ∘ part₂ $ input

--------------------------------------------------------------------------------
-- Lemmas

module _ where

  split2ᵇ-lemma-1 : split2ᵇ (_≈ᵇ '\n') "1\n2" ≡ just ("1" , "2")
  split2ᵇ-lemma-1 = refl

  split2ᵇ-lemma-2 : split2ᵇ (_≈ᵇ '\n') "1" ≡ nothing
  split2ᵇ-lemma-2 = refl

  split2ᵇ-lemma-3 : split2ᵇ (_≈ᵇ '\n') "1\n2\n3" ≡ nothing
  split2ᵇ-lemma-3 = refl

  lines-lemma : lines "a\nb\nc\nd" ≡ "a" ∷ "b" ∷ "c" ∷ "d" ∷ []
  lines-lemma = refl

  parse-lemma : (parse "1-2,3-4") ≡ [((1 , 2) , (3 , 4))]
  parse-lemma = refl

  parse-lemma-2 : (parse "1-2,3-4\nna") ≡ ((1 , 2) , (3 , 4)) ∷ []
  parse-lemma-2 = refl

  parse-lemma-3 : (parse "1-2,3-4\n5-6,7-8") ≡
    ((1 , 2) , (3 , 4))
    ∷ ((5 , 6) , (7 , 8))
    ∷ []
  parse-lemma-3 = refl

  -- Input lemmas

  example-input : String
  example-input =
            "2-4,6-8\n\
            \2-3,4-5\n\
            \5-7,7-9\n\
            \2-8,3-7\n\
            \6-6,4-6\n\
            \2-6,4-8\n"

  lines-expected : List String
  lines-expected
    = "2-4,6-8"
    ∷ "2-3,4-5"
    ∷ "5-7,7-9"
    ∷ "2-8,3-7"
    ∷ "6-6,4-6"
    ∷ "2-6,4-8"
    ∷ []

  lines-lemma-example : (lines example-input) ≡ lines-expected
  lines-lemma-example = refl

  example-expected : List ((ℕ × ℕ) × (ℕ × ℕ))
  example-expected
    = ((2 , 4) , (6 , 8))
    ∷ ((2 , 3) , (4 , 5))
    ∷ ((5 , 7) , (7 , 9))
    ∷ ((2 , 8) , (3 , 7))
    ∷ ((6 , 6) , (4 , 6))
    ∷ ((2 , 6) , (4 , 8))
    ∷ []

  parse-lemma-example : parse (example-input) ≡ example-expected
  parse-lemma-example = refl

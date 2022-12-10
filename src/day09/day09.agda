{-# OPTIONS --guardedness #-}

module day09 where

open import Data.Bool using (Bool; true; false; _∧_)
open import Data.Integer as I using (ℤ; SignAbs; _◂_; signAbs; _+_; _-_; _*_; ∣_∣; 0ℤ; 1ℤ; -1ℤ)
open import Data.Integer.Show as IS using ()
open import Data.List as L using (List; _∷_; []; [_]; concat; deduplicateᵇ; foldl; length; mapMaybe)
open import Data.Maybe using (Maybe; just; nothing; map)
open import Data.Nat using (ℕ; suc; zero; _≤ᵇ_; _⊔′_)
open import Data.Nat.Show using (readMaybe; show)
open import Data.Product using (_×_; _,_; proj₁; uncurry)
open import Data.Sign as S using (Sign)
open import Data.String using (String; unlines; words; lines; _++_)
open import Data.Vec as V using (Vec; last; replicate; toList)
open import Function using (id; _$_; _∘_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Relation.Nullary.Decidable using (⌊_⌋)

2ℤ : ℤ
2ℤ = 1ℤ + 1ℤ

data Direction : Set where
  up    : Direction
  down  : Direction
  left  : Direction
  right : Direction

data Instruction : Set where
  instruction : Direction → ℕ → Instruction

data Point : Set where
  point : ℤ → ℤ → Point

_=ᵇ_ : Point → Point → Bool
point x₁ y₁ =ᵇ point x₂ y₂ = ⌊ x₁ I.≟ x₂ ⌋ ∧ ⌊ y₁ I.≟ y₂ ⌋

show-Point : Point → String
show-Point (point x y) = (IS.show x) ++ ", " ++ (IS.show y)

data History : Set where
  history : List Point → History

move-point : Direction → Point → Point
move-point up    (point x y) = point  x       (y + 1ℤ)
move-point down  (point x y) = point  x       (y - 1ℤ)
move-point left  (point x y) = point (x - 1ℤ)  y
move-point right (point x y) = point (x + 1ℤ)  y

module Vectors where
  open import Data.Vec using (_∷_; []; [_])

  move-head : ∀ {n} → Direction → Vec Point (suc n) → Vec Point (suc n)
  move-head d (x ∷ v) = move-point d x ∷ v

  -- aka tail
  behead : ∀ {n a} {A : Set a} → Vec A (suc n) → Vec A n
  behead (x ∷ v) = v

  -- aka init
  curtail : ∀ {n a} {A : Set a} → Vec A (suc n) → Vec A n
  curtail (x ∷ []) = []
  curtail (x ∷ v) = curtail′ x v
    where
      curtail′ : ∀ {n a} {A : Set a} → A → Vec A n → Vec A n
      curtail′ _ [] = []
      curtail′ y (z ∷ zs) = y ∷ curtail′ z zs 

  scanl : ∀ {n a b} {A : Set a} {B : Set b} → (A → B → A) → A → Vec B n → Vec A (suc n)
  scanl f e []       = e ∷ []
  scanl f e (x ∷ xs) = e ∷ scanl f (f e x) xs

  scanl1 : ∀ {n a} {A : Set a} → (A → A → A) → Vec A n → Vec A n
  scanl1 f [] = []
  scanl1 f (x ∷ v) = scanl f x v

open Vectors

signum : ℤ → ℤ
signum I.+0 = 0ℤ
signum I.+[1+ n ] = 1ℤ
signum I.-[1+ n ] = -1ℤ

_touching?_ : Point → Point → Bool
point x₁ y₁ touching? point x₂ y₂ = ∣ x₁ - x₂ ∣ ⊔′ ∣ y₁ - y₂ ∣ ≤ᵇ 1

yank-tail : Point → Point → Point
yank-tail h@(point xₕ yₕ) t@(point xₜ yₜ) with h touching? t
... | true  = t
... | false =
  let xₜ′ = xₜ + signum (xₕ - xₜ)
      yₜ′ = yₜ + signum (yₕ - yₜ)
  in point xₜ′ yₜ′

yank : ∀ {n} → Vec Point n → Vec Point n
yank {n} = scanl1 yank-tail

execute-instruction : ∀ {n} → History → Vec Point (suc n) → Instruction → History × Vec Point (suc n)
execute-instruction hist r (instruction _ zero) = hist , r
execute-instruction (history hist) rope (instruction d (suc i)) =
  let r′ = yank $ move-head d rope in
  execute-instruction (history (last r′ ∷ hist)) r′ (instruction d i)

parse : String → List Instruction
parse = mapMaybe (parse-instruction ∘ words) ∘ lines
  where
    parse-instruction : List String → Maybe Instruction
    parse-instruction ("U" ∷ n ∷ []) = map (instruction up)    $ readMaybe 10 n
    parse-instruction ("D" ∷ n ∷ []) = map (instruction down)  $ readMaybe 10 n
    parse-instruction ("L" ∷ n ∷ []) = map (instruction left)  $ readMaybe 10 n
    parse-instruction ("R" ∷ n ∷ []) = map (instruction right) $ readMaybe 10 n
    parse-instruction otherwise      = nothing

part : ℕ → List Instruction → ℕ
part 0 _ = 0
part n@(suc _) is = count ∘ proj₁ ∘ (foldl (uncurry execute-instruction) (starting-history , starting-rope)) $ is
  where
    count : History → ℕ
    count (history x) = length ∘ (deduplicateᵇ _=ᵇ_) $ x
    starting-history : History
    starting-history = history []
    starting-rope : Vec Point n
    starting-rope = replicate (point 0ℤ 0ℤ)

part₁ : List Instruction → ℕ
part₁ = part 2

part₂ : List Instruction → ℕ
part₂ = part 10

module _ where
  open import Data.Unit.Polymorphic
  open import IO
  open import IO.Finite
  open import System.Environment

  main : Main
  main = run $ getArgs >>= process
    where
      process : List String → IO ⊤
      process [] = putStrLn "No input provided"
      process (s ∷ _) = do 
        contents ← readFile s
        let input = parse contents
        putStrLn ∘ show ∘ part₁ $ input
        putStrLn ∘ show ∘ part₂ $ input

module _ where
  example-input-1 : String
  example-input-1 =
    "R 4\n\
    \U 4\n\
    \L 3\n\
    \D 1\n\
    \R 4\n\
    \D 1\n\
    \L 5\n\
    \R 2\n"

  expected-instructions-1 : List Instruction
  expected-instructions-1
    = instruction right 4
    ∷ instruction up    4
    ∷ instruction left  3
    ∷ instruction down  1
    ∷ instruction right 4
    ∷ instruction down  1
    ∷ instruction left  5
    ∷ instruction right 2
    ∷ []

  example-input-2 : String
  example-input-2 =
    "R 5\n\
    \U 8\n\
    \L 8\n\
    \D 3\n\
    \R 17\n\
    \D 10\n\
    \L 25\n\
    \U 20\n"

  expected-instructions-2 : List Instruction
  expected-instructions-2
    = instruction right  5
    ∷ instruction up     8
    ∷ instruction left   8
    ∷ instruction down   3
    ∷ instruction right 17
    ∷ instruction down  10
    ∷ instruction left  25
    ∷ instruction up    20
    ∷ []

  parses-example-lemma-1 : parse example-input-1 ≡ expected-instructions-1
  parses-example-lemma-1 = refl

  parses-example-lemma-2 : parse example-input-2 ≡ expected-instructions-2
  parses-example-lemma-2 = refl

  part₁-lemma : part₁ expected-instructions-1 ≡ 13
  part₁-lemma = refl

  part₂-lemma-1 : part₂ expected-instructions-1 ≡ 1
  part₂-lemma-1 = refl

  part₂-lemma-2 : part₂ expected-instructions-2 ≡ 36
  part₂-lemma-2 = refl

  yank-tail-lemma-right : yank-tail (point 0ℤ 0ℤ) (point 2ℤ 0ℤ) ≡ point 1ℤ 0ℤ
  yank-tail-lemma-right = refl

  yank-tail-lemma-left : yank-tail (point 2ℤ 0ℤ) (point 0ℤ 0ℤ) ≡ point 1ℤ 0ℤ
  yank-tail-lemma-left = refl

  yank-tail-lemma-up : yank-tail (point 0ℤ 2ℤ) (point 0ℤ 0ℤ) ≡ point 0ℤ 1ℤ
  yank-tail-lemma-up = refl

  yank-tail-lemma-down : yank-tail (point 0ℤ 0ℤ) (point 0ℤ 2ℤ) ≡ point 0ℤ 1ℤ
  yank-tail-lemma-down = refl

  yank-tail-lemma-up-right : yank-tail (point 1ℤ 2ℤ) (point 0ℤ 0ℤ) ≡ point 1ℤ 1ℤ
  yank-tail-lemma-up-right = refl

  yank-tail-lemma-up-left : yank-tail (point 0ℤ 2ℤ) (point 2ℤ 0ℤ) ≡ point 1ℤ 1ℤ
  yank-tail-lemma-up-left = refl

  yank-tail-lemma-down-right : yank-tail (point 0ℤ 2ℤ) (point 2ℤ 0ℤ) ≡ point 1ℤ 1ℤ
  yank-tail-lemma-down-right = refl

  yank-tail-lemma-down-left : yank-tail (point 2ℤ 2ℤ) (point 0ℤ 0ℤ) ≡ point 1ℤ 1ℤ
  yank-tail-lemma-down-left = refl

  signum-lemma-0 : signum 0ℤ ≡ 0ℤ
  signum-lemma-0 = refl

  signum-thm-1 : ∀ {n} → signum (I.+ (suc n)) ≡ 1ℤ
  signum-thm-1 = refl

  signum-thm-2 : ∀ {n} → signum (I.+[1+ n ]) ≡ 1ℤ
  signum-thm-2 = refl

  signum-thm-3 : ∀ {n} → signum (I.-[1+ n ]) ≡ -1ℤ
  signum-thm-3 = refl

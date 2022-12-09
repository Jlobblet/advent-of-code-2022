{-# OPTIONS --guardedness #-}

module day09 where

open import Data.Bool using (Bool; true; false; _∧_)
open import Data.Integer as I using (ℤ; _+_; _-_; ∣_∣; 0ℤ; 1ℤ)
open import Data.Integer.Show as IS using ()
open import Data.List as L using (List; _∷_; []; [_]; deduplicateᵇ; foldl; length; mapMaybe)
open import Data.Maybe using (Maybe; just; nothing; map)
open import Data.Nat using (ℕ; suc; zero; _≤ᵇ_; _⊔′_)
open import Data.Nat.Show using (readMaybe; show)
open import Data.Product using (_×_; _,_; proj₁; uncurry)
open import Data.String using (String; unlines; words; lines; _++_)
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

_≟_ : Point → Point → Bool
point x₁ y₁ ≟ point x₂ y₂ = ⌊ x₁ I.≟ x₂ ⌋ ∧ ⌊ y₁ I.≟ y₂ ⌋

show-Point : Point → String
show-Point (point x y) = (IS.show x) ++ ", " ++ (IS.show y)

data History : Set where
  history : List Point → History

extract : History → List Point
extract (history h) = h

data Rope : Set where
  rope : Point → Point → Rope

tail : Rope → Point
tail (rope h t) = t

move-point : Direction → Point → Point
move-point up    (point x y) = point  x       (y + 1ℤ)
move-point down  (point x y) = point  x       (y - 1ℤ)
move-point left  (point x y) = point (x - 1ℤ)  y
move-point right (point x y) = point (x + 1ℤ)  y

_touching?_ : Point → Point → Bool
point x₁ y₁ touching? point x₂ y₂ = ∣ x₁ - x₂ ∣ ⊔′ ∣ y₁ - y₂ ∣ ≤ᵇ 1

yank-tail : Rope → Rope
yank-tail r@(rope h@(point xₕ yₕ) t@(point xₜ yₜ)) with h touching? t
... | true = r
... | false =
  let ─ = xₕ  ─′ xₜ
      │ = yₕ │′ yₜ
  in rope h (│ ∘ ─ $ t)
  where
    _─′_ : ℤ → ℤ → (Point → Point)
    h ─′ t with h I.≤ᵇ t | t I.≤ᵇ h 
    ... | true | true = id
    ... | true | false = move-point left
    ... | false | true = move-point right
    ... | false | false = id -- unreachable
    _│′_ : ℤ → ℤ → (Point → Point)
    h │′ t with h I.≤ᵇ t | t I.≤ᵇ h 
    ... | true | true = id
    ... | true | false = move-point down
    ... | false | true = move-point up
    ... | false | false = id -- unreachable

execute-instruction : History → Rope → Instruction → History × Rope
execute-instruction hist r (instruction _ zero) = hist , r
execute-instruction (history hist) (rope h t) (instruction d (suc n)) =
  let h′ = move-point d h
      r′ = yank-tail $ rope h′ t
      in
  execute-instruction (history (tail r′ ∷ hist)) r′ $ instruction d n

parse : String → List Instruction
parse = mapMaybe (parse-instruction ∘ words) ∘ lines
  where
    parse-instruction : List String → Maybe Instruction
    parse-instruction ("U" ∷ n ∷ []) = map (instruction up)    $ readMaybe 10 n
    parse-instruction ("D" ∷ n ∷ []) = map (instruction down)  $ readMaybe 10 n
    parse-instruction ("L" ∷ n ∷ []) = map (instruction left)  $ readMaybe 10 n
    parse-instruction ("R" ∷ n ∷ []) = map (instruction right) $ readMaybe 10 n
    parse-instruction otherwise      = nothing

part₁ : List Instruction → ℕ
part₁ is = count ∘ proj₁ ∘ (foldl (uncurry execute-instruction) (starting-history , starting-rope)) $ is
  where
    count : History → ℕ
    count (history x) = length ∘ (deduplicateᵇ _≟_) $ x
    starting-history : History
    starting-history = history []
    starting-rope : Rope
    starting-rope = rope (point 0ℤ 0ℤ) (point 0ℤ 0ℤ)

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
      process (s ∷ _) = readFile s >>= (putStrLn ∘ show ∘ part₁ ∘ parse)

module _ where
  example-input : String
  example-input =
    "R 4\n\
    \U 4\n\
    \L 3\n\
    \D 1\n\
    \R 4\n\
    \D 1\n\
    \L 5\n\
    \R 2\n"

  expected-instructions : List Instruction
  expected-instructions
    = instruction right 4
    ∷ instruction up    4
    ∷ instruction left  3
    ∷ instruction down  1
    ∷ instruction right 4
    ∷ instruction down  1
    ∷ instruction left  5
    ∷ instruction right 2
    ∷ []

  parses-example-lemma : parse example-input ≡ expected-instructions
  parses-example-lemma = refl

  part₁-lemma : part₁ expected-instructions ≡ 13
  part₁-lemma = refl

  yank-tail-lemma-right : yank-tail (rope (point 2ℤ 0ℤ) (point 0ℤ 0ℤ))
    ≡ rope (point 2ℤ 0ℤ) (point 1ℤ 0ℤ)
  yank-tail-lemma-right =  refl

  yank-tail-lemma-left : yank-tail (rope (point 0ℤ 0ℤ) (point 2ℤ 0ℤ))
    ≡  rope (point 0ℤ 0ℤ) (point 1ℤ 0ℤ)
  yank-tail-lemma-left = refl

  yank-tail-lemma-up : yank-tail (rope (point 0ℤ 2ℤ) (point 0ℤ 0ℤ))
    ≡ rope (point 0ℤ 2ℤ) (point 0ℤ 1ℤ)
  yank-tail-lemma-up = refl

  yank-tail-lemma-down : yank-tail (rope (point 0ℤ 0ℤ) (point 0ℤ 2ℤ))
    ≡ rope (point 0ℤ 0ℤ) (point 0ℤ 1ℤ)
  yank-tail-lemma-down = refl

-- | Type-level functions for working with type-level
-- | values.
module Type.ShuntingYard.Prelude where

import Type.ShuntingYard.Evaluate

import Prim.Boolean (False, True)
import Prim.Symbol as Symbol
import Type.Data.Boolean (class If, class Not)
import Type.Data.List (class IsMember, type (:>), List', Nil')
import Type.ShuntingYard.Types (PairK, type (\/))

class MapT ∷ ∀ k l. (k → TypeExpr l) → List' k → List' l → Constraint
class MapT f xs ys | f xs → ys

instance mapNil ∷ MapT f Nil' Nil'

else instance mapRec ∷
  ( Evaluate (f x) y
  , MapT f xs ys
  ) ⇒
  MapT f (x :> xs) (y :> ys)

foreign import data Map
  ∷ ∀ k l
  . (k → TypeExpr l)
  → List' k
  → TypeExpr (List' l)

instance mapEvaluate ∷ MapT f xs ys ⇒ Evaluate (Map f xs) ys

class FilterT ∷ ∀ k. (k → TypeExpr Boolean) → List' k → List' k → Constraint
class FilterT f xs ys | f xs → ys

instance filterNil ∷ FilterT f Nil' Nil'

else instance filterRec ∷
  ( Evaluate (f x) r
  , FilterT f xs ys
  , If r (x :> ys) ys zs
  ) ⇒
  FilterT f (x :> xs) zs

foreign import data Filter
  ∷ ∀ k
  . (k → TypeExpr Boolean)
  → List' k
  → TypeExpr (List' k)

instance filterEvaluate ∷ FilterT f xs ys ⇒ Evaluate (Filter f xs) ys

class GroupByT ∷ ∀ k. (k → k → TypeExpr Boolean) → List' k → List' (List' k) → Constraint
class GroupByT f xs ys | f xs → ys

instance groupByTNil ∷ GroupByT f Nil' Nil'

else instance groupByTRec ∷
  ( SpanT (f x) xs (ys \/ zs)
  , GroupByT f zs zs'
  ) ⇒
  GroupByT f (x :> xs) ((x :> ys) :> zs')

foreign import data GroupBy
  ∷ ∀ k
  . (k → k → TypeExpr Boolean)
  → List' k
  → TypeExpr (List' (List' k))

instance groupByEvaluate ∷ GroupByT f xs ys ⇒ Evaluate (GroupBy f xs) ys

class TypeEqualsTF ∷ ∀ k. k → k → Boolean → Constraint
class TypeEqualsTF a b r | a b → r

instance typeEqualsT ∷ TypeEqualsTF a a True

else instance typeEqualsF ∷ TypeEqualsTF a b False

foreign import data Equals ∷ ∀ k. k → k → TypeExpr Boolean

instance equalsEvaluate ∷ TypeEqualsTF a b r ⇒ Evaluate (Equals a b) r

foreign import data NotEquals ∷ ∀ k. k → k → TypeExpr Boolean

instance notEqualsEvaluate ∷
  ( TypeEqualsTF a b r_
  , Not r_ r
  ) ⇒
  Evaluate (NotEquals a b) r

foreign import data Member ∷ ∀ k. k → List' k → TypeExpr Boolean

instance memberEvaluate ∷
  ( IsMember x xs r
  ) ⇒
  Evaluate (Member x xs) r

foreign import data IsNatural ∷ Symbol → TypeExpr Boolean

type Naturals =
  "0" :> "1" :> "2" :> "3" :> "4"
    :> "5"
    :> "6"
    :> "7"
    :> "8"
    :> "9"
    :> Nil'

instance isNaturalEvaluate ∷
  ( IsMember n Naturals r
  ) ⇒
  Evaluate (IsNatural n) r

foreign import data IsOperator ∷ Symbol → TypeExpr Boolean

type Operators =
  "*" :> "/"
    :> "+"
    :> "-"
    :> "("
    :> ")"
    :> Nil'

instance isOperatorEvaluate ∷
  ( IsMember o Operators r
  ) ⇒
  Evaluate (IsOperator o) r

class SpanT ∷ ∀ k. (k → TypeExpr Boolean) → List' k → PairK (List' k) (List' k) → Constraint
class SpanT p xs r | p xs → r

instance spanTNil ∷ SpanT p Nil' (Nil' \/ Nil')

else instance spanTRec ∷
  ( Evaluate (p x) c
  , SpanT p xs' (ys \/ zs)
  , If c (x :> ys \/ zs) (Nil' \/ x :> xs') r
  ) ⇒
  SpanT p (x :> xs') r

foreign import data Span
  ∷ ∀ k
  . (k → TypeExpr Boolean)
  → List' k
  → TypeExpr (PairK (List' k) (List' k))

instance spanEvaluate ∷ SpanT p xs r ⇒ Evaluate (Span p xs) r

class BreakT ∷ ∀ k. (k → TypeExpr Boolean) → List' k → PairK (List' k) (List' k) → Constraint
class BreakT p xs r | p xs → r

instance breakTNil ∷ BreakT p Nil' (Nil' \/ Nil')

else instance breakTRec ∷
  ( Evaluate (p x) c
  , BreakT p xs' (ys \/ zs)
  , If c (Nil' \/ x :> xs') (x :> ys \/ zs) r
  ) ⇒
  BreakT p (x :> xs') r

foreign import data Break
  ∷ ∀ k
  . (k → TypeExpr Boolean)
  → List' k
  → TypeExpr (PairK (List' k) (List' k))

instance breakEvalaute ∷ BreakT p xs r ⇒ Evaluate (Break p xs) r

class DropWhileT ∷ ∀ k. (k → TypeExpr Boolean) → List' k → List' k → Constraint
class DropWhileT p xs ys | p xs → ys

instance dropWhileTImpl ∷ SpanT p xs (_ys \/ zs) ⇒ DropWhileT p xs zs

foreign import data DropWhile
  ∷ ∀ k
  . (k → TypeExpr Boolean)
  → List' k
  → TypeExpr (List' k)

instance dropWhileEvaluate ∷ DropWhileT p xs r ⇒ Evaluate (DropWhile p xs) r

class TakeWhileT ∷ ∀ k. (k → TypeExpr Boolean) → List' k → List' k → Constraint
class TakeWhileT p xs ys | p xs → ys

instance takeWhileTImpl ∷ SpanT p xs (ys \/ _zs) ⇒ TakeWhileT p xs ys

foreign import data TakeWhile
  ∷ ∀ k
  . (k → TypeExpr Boolean)
  → List' k
  → TypeExpr (List' k)

instance takeWhileEvaluate ∷ TakeWhileT p xs r ⇒ Evaluate (TakeWhile p xs) r

class ChopT (s ∷ Symbol) (r ∷ List' Symbol) | s → r

instance chopNil ∷ ChopT "" Nil'

else instance chopRec ∷
  ( Symbol.Cons h t s
  , ChopT t t'
  ) ⇒
  ChopT s (h :> t')

foreign import data Chop ∷ Symbol → TypeExpr (List' Symbol)

instance chopEvaluate ∷ ChopT s r ⇒ Evaluate (Chop s) r

class JoinT (c ∷ List' Symbol) (r ∷ Symbol) | c → r

instance joinTNil ∷ JoinT Nil' ""

else instance joinTRec ∷
  ( JoinT xs t
  , Symbol.Cons h t r
  ) ⇒
  JoinT (h :> xs) r

foreign import data Join ∷ (List' Symbol) → TypeExpr Symbol

instance joinEvaluate ∷ JoinT c r ⇒ Evaluate (Join c) r

class WordsT (s ∷ Symbol) (r ∷ List' Symbol) | s → r

instance wordsTNil ∷ WordsT "" Nil'

else instance wordsRec ∷
  ( ChopT sentence chars
  , DropWhileT (Equals " ") chars clean
  , BreakT (Equals " ") clean (wordL \/ nextL)
  , JoinT wordL word
  , JoinT nextL next_
  , WordsT next_ next
  ) ⇒
  WordsT sentence (word :> next)

foreign import data Words ∷ Symbol → TypeExpr (List' Symbol)

instance wordsEvaluate ∷ WordsT s r ⇒ Evaluate (Words s) r

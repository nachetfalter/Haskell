{-# LANGUAGE GADTs, DataKinds, KindSignatures #-}
module Ex09 where

data Nat = Z | S Nat 

data SNat :: Nat -> * where
  SZero :: SNat Z
  SSucc :: SNat n -> SNat (S n)

data LessEq :: Nat -> Nat -> * where
  ZLEN :: LessEq Z n
  SLES :: LessEq n m -> LessEq (S n) (S m)

{--E n m, E m d--}
reflexivity :: SNat n -> LessEq n n
reflexivity SZero = ZLEN
reflexivity (SSucc n) = SLES (reflexivity n)

transitivity :: LessEq a b -> LessEq b c -> LessEq a c
transitivity ZLEN ZLEN = ZLEN
transitivity ZLEN (SLES n) = ZLEN
transitivity (SLES n) (SLES m) = SLES (transitivity n m)

data Equal :: Nat -> Nat -> * where
  EqRefl :: Equal n n

antisymmetry :: LessEq a b -> LessEq b a -> Equal a b
antisymmetry ZLEN ZLEN = EqRefl
antisymmetry (SLES a) (SLES b)  = case (antisymmetry a b) of
                                    EqRefl -> EqRefl
    {--antisymmetry a b--}


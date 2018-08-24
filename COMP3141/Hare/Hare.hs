{-# LANGUAGE GADTs, DataKinds, KindSignatures, TupleSections, PolyKinds, TypeOperators, TypeFamilies, PartialTypeSignatures #-}
module Hare where
import Control.Monad
import Control.Applicative 
import HareMonad

data RE :: * -> * where 
  Empty :: RE ()
  Fail :: RE a
  Char :: [Char] -> RE Char
  Seq :: RE a -> RE b -> RE (a, b)
  Choose :: RE a -> RE a -> RE a
  Star :: RE a -> RE [a]
  Action :: (a -> b) -> RE a -> RE b

match :: (Alternative f, Monad f) => RE a -> Hare f a
match Empty = pure ()
match Fail = failure
match (Char cs) = do 
    x <- readCharacter
    guard (x `elem` cs)
    pure (x)
match (Seq a b) = do 
    ra <- match a 
    rb <- match b  
    pure (ra, rb)
match (Choose a b) = 
        match a
    <|> match b
match (Star a) =
        addFront <$> match a <*> match (Star a)
    <|> pure ([])
  where 
    addFront x xs = x:xs
match (Action f x) = fmap f (match x)

matchAnywhere :: (Alternative f, Monad f) => RE a -> Hare f a
matchAnywhere re = match re <|> (readCharacter >> matchAnywhere re)

(=~) :: (Alternative f, Monad f) => String -> RE a -> f a 
(=~) = flip (hare . matchAnywhere)

infixr `cons`  
cons :: RE a -> RE [a] -> RE [a]
cons x xs = Action (\x->(fst x):(snd x)) (Seq x xs)

plus :: RE a -> RE [a]
plus re = Action (\x->(fst x):(snd x)) (Seq re (Star re))

string :: String -> RE String
string [] = Action (\x->[]) Empty
string (x:xs) = Action (\z->(fst z) ++ (snd z)) (Seq ((\y->cons (Char y) (Action (\x->[]) Empty)) [x])  (string xs))

choose :: [RE a] -> RE a
choose [] = Fail 
choose (x:xs) = Choose x (choose xs) 

option :: RE a -> RE (Maybe a)
option re = Choose (Action (\x->Just x) re) (Action (\x->Nothing) Empty)

rpt :: Int -> RE a -> RE [a]
rpt 0 re = Action (\x->[]) Empty
rpt n re = cons re (rpt (n-1) re)

rptRange :: (Int, Int) -> RE a -> RE [a]
rptRange (x, y) re = if (x == y)
                     then rpt x re
                     else Choose (rpt y re) (rptRange (x, y-1) re)





module Ex04 where

import Text.Read (readMaybe)
import Data.Maybe
import Control.Exception
import Data.Typeable

data Token = Number Int | Operator (Int -> Int -> Int)

parseToken :: String -> Maybe Token
parseToken "+" = Just (Operator (+))
parseToken "-" = Just (Operator (-))
parseToken "/" = Just (Operator div)
parseToken "*" = Just (Operator (*))
parseToken str = fmap Number (readMaybe str)

tokenise :: String -> Maybe [Token]
tokenise xs = if (length (fmap parseToken (words xs)) == length (concat (map (\x -> maybeToList x) (fmap parseToken (words xs)))))
              then Just (concat (map (\x -> maybeToList x) (fmap parseToken (words xs))))
              else Nothing

newtype Calc a = C ([Int] -> Maybe ([Int], a))

pop :: Calc Int
pop = C (pop')
      where
      pop' :: [Int] -> Maybe ([Int], Int)
      pop' inputStack = if length inputStack == 0
                        then Nothing
                        else Just((tail inputStack), x)
                        where
                        x = head inputStack

push :: Int -> Calc ()
push i = C (push' i)
          where
          push' :: Int -> [Int] -> Maybe([Int],())
          push' i inputStack = Just([i] ++ inputStack, ())


instance Functor Calc where
  fmap f (C sa) = C $ \s ->
      case sa s of 
        Nothing      -> Nothing
        Just (s', a) -> Just (s', f a)

instance Applicative Calc where
  pure x = C (\s -> Just (s,x))
  C sf <*> C sx = C $ \s -> 
      case sf s of 
          Nothing     -> Nothing
          Just (s',f) -> case sx s' of
              Nothing      -> Nothing
              Just (s'',x) -> Just (s'', f x)

instance Monad Calc where
  return = pure
  C sa >>= f = C $ \s -> 
      case sa s of 
          Nothing     -> Nothing
          Just (s',a) -> unwrapCalc (f a) s'
    where unwrapCalc (C a) = a

evaluate :: [Token] -> Calc Int
evaluate t c = C (evaluate' t c)
              where
              evaluate' :: [Token] -> Calc a -> [Int] -> Maybe ([Int], Int)
              evaluate' t stack = Just((stackopt t stack), head (stackopt t stack)



stackopt :: [Token] -> [Int]
stackopt t stack = map (\x -> if isInteger x == True
                              then push x
                              else do a <- pop
                                      b <- pop
                                      push a x b) t


addTwo :: Calc ()
addTwo = do
  x <- pop
  y <- pop
  push (x + y)

calculate :: String -> Maybe Int
calculate s = Just 1

runCalc :: Calc a -> [Int] -> Maybe ([Int],a)
runCalc C a = a

{-# LANGUAGE GADTs, EmptyDataDecls, TypeFamilies, TypeOperators, DataKinds, FlexibleInstances #-}
module Ex06 where

data Format (fmt :: [*])  where
  X :: Format '[]
  L :: String -> Format xs -> Format xs
  S :: Format (fmt) -> Format (String ': fmt)
  I :: Format (fmt) -> Format (Int ': fmt)

type family FormatArgsThen (fmt :: [*]) (ty :: *) :: *
type instance FormatArgsThen '[]       ty = ty
type instance FormatArgsThen (t ': ts) ty = t  -> FormatArgsThen ts ty  
     
printf :: Format fmt -> FormatArgsThen fmt String
printf fmt = printf' fmt ""
   where
      printf' :: Format fmt -> String -> FormatArgsThen fmt String
      printf' X = id
      printf' (L str fmt) = \str2 -> printf' fmt (str2 ++ str)
      printf' (I fmt) = \str -> \i -> printf' fmt (str ++ show(i))
      printf' (S fmt) = \str -> \s -> printf' fmt (str ++ s)
      printf _ _ = error "format string and argument mismatch"
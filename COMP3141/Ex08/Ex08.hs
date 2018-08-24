{-# LANGUAGE GADTs, DataKinds, KindSignatures, RankNTypes, StandaloneDeriving #-}
module Ex08 where
import Data.List (delete)
import Data.Maybe

data City = Sydney | Shanghai | Seoul | Singapore | Sapporo deriving (Eq, Show, Enum)

allCities :: [City]
allCities = [Sydney ..]

data SCity :: City -> * where
  SSydney    :: SCity Sydney
  SShanghai  :: SCity Shanghai
  SSeoul     :: SCity Seoul
  SSingapore :: SCity Singapore
  SSapporo   :: SCity Sapporo

untype :: SCity s -> City
untype SSydney    = Sydney
untype SShanghai  = Shanghai
untype SSeoul     = Seoul
untype SSingapore = Singapore
untype SSapporo   = Sapporo

withTyped :: (forall c. SCity c -> b) -> City -> b
withTyped f Sydney    = f SSydney
withTyped f Shanghai  = f SShanghai
withTyped f Seoul     = f SSeoul
withTyped f Singapore = f SSingapore
withTyped f Sapporo   = f SSapporo

data Flight :: City -> City -> * where
  NH880 :: Flight Sydney Sapporo
  SQ222 :: Flight Sydney Singapore
  KE122 :: Flight Sydney Seoul
  KE121 :: Flight Seoul Sydney
  SQ825 :: Flight Shanghai Singapore
  SQ231 :: Flight Singapore Sydney
  KE893 :: Flight Seoul Shanghai

deriving instance Show (Flight a b)

data Journey :: City -> City -> * where
  Fly :: Flight a b -> Journey a b
  Connect :: Journey a b -> Journey b c -> Journey a c

deriving instance Show (Journey a b)

flight :: SCity a -> SCity b -> Maybe(Flight a b)
flight SSydney SSapporo = Just(NH880)
flight SSydney SSingapore = Just(SQ222)
flight SSydney SSeoul = Just(KE122)
flight SSeoul SSydney = Just(KE121)
flight SShanghai SSingapore = Just(SQ825)
flight SSingapore SSydney = Just(SQ231)
flight SSeoul SShanghai = Just(KE893)
flight _ _ = Nothing

journeys :: [City] -> SCity a -> SCity b -> [Journey a b]
journeys [] a b = []
journeys cs a b = unpack (flight a b) ++ (map (\x->withTyped (\y-> Connect (journeys'' (delete (untype y) (take (length cs) cs)) a y) (journeys'' (delete (untype y) (take (length cs) cs)) y b)) x) cs)

journeys'' :: [City] -> SCity a -> SCity b -> Journey a b

journeys'' cs a b = journeys'' withTyped (\y->half (tail cs) a y b) (head cs)

half :: [City] -> SCity a -> SCity b -> SCity c -> Journey a c
half cs a b c = Connect (journeys' (delete (untype b) (take (length cs) cs)) a b b) (journeys' (delete (untype b) (take (length cs) cs)) b b c)

journeys' :: [City] -> SCity a -> SCity b -> SCity c -> Journey a c 
journeys' [] a b c = head (unpack (flight a c))
journeys' cs a b c =
                    if length (unpack (flight a c)) > 0
                    then head (unpack (flight a c))
                    else
                    if length (unpack (flight a b)) > 0
                    then
                        if length cs > 1
                        then Connect (head (unpack (flight a b))) (withTyped (\x-> journeys' (delete (untype b) (take (length cs) cs)) b x c) ((take (length cs) cs)!!1))
                        else Connect (head (unpack (flight a b))) (withTyped (\x-> journeys' (delete (untype b) (take (length cs) cs)) b x c) (Shanghai))
                    else
                        withTyped (\x -> journeys' cs a x c) (head (delete (untype b) (take (length cs) cs)))

unpack :: Maybe(Flight x y) -> [Journey x y]
unpack a = case(a) of
            Nothing -> []
            Just x -> [Fly x]


{--if length (unpack (flight a b)) > 0
                    then
                        if length cs > 1
                        then Connect (head (unpack (flight a b))) (withTyped (\x-> journeys' (delete (untype b) (take (length cs) cs)) b x c) ((take (length cs) cs)!!1))
                        else Connect (head (unpack (flight a b))) (withTyped (\x-> journeys' (delete (untype b) (take (length cs) cs)) b x c) (Shanghai))
                    else
                        withTyped (\x -> journeys' cs a x b) (head (delete (untype b) (take (length cs) cs))) 



                        (Connect (withTyped (\x -> journeys'' cs a x) (head (delete (untype b) (take (length cs) cs)))) (withTyped (\x -> journeys'' cs x b) (head (delete (untype b) (take (length cs) cs))))) --}

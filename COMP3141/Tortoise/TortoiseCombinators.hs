module TortoiseCombinators
       ( andThen 
       , loop 
       , invisibly 
       , retrace 
       , overlay 
       ) where

import Tortoise

-- See Tests.hs or the assignment spec for specifications for each
-- of these combinators.

andThen :: Instructions -> Instructions -> Instructions
andThen i1 Stop = i1
andThen Stop i2 = i2
andThen (Move a b) i2 = (Move a (andThen b i2))
andThen (Turn a b) i2 = (Turn a (andThen b i2))
andThen (SetStyle a b) i2 = (SetStyle a (andThen b i2))
andThen (SetColour a b) i2 = (SetColour a (andThen b i2))
andThen (PenDown a) i2 = (PenDown (andThen a i2))
andThen (PenUp a) i2 = (PenUp (andThen a i2))

loop :: Int -> Instructions -> Instructions
loop n i | n <= 0 = Stop
         | n > 0 = i `andThen` (loop (n-1) i)

invisibly :: Instructions -> Instructions
invisibly i = snd $ processIns(True, i)
            where
            processIns :: (Bool, Instructions) -> (Bool, Instructions)
            processIns (b, Stop) = (b, Stop)
            processIns (b, (PenDown a)) = (True, PenDown (snd(processIns (True, a))))
            processIns (b, (PenUp a)) = (False, PenUp (snd(processIns (False, a))))
            processIns (b, (Move a c)) | b == True = (True, (snd ( processIns (True, ((PenUp Stop) 
                                         `andThen` (Move a Stop) `andThen` (PenDown c))))))
                                       | b == False = (False, Move a (snd(processIns (False, c))))
            processIns (b, (Turn a c)) = (b, (Turn a (snd(processIns (b, c)))))
            processIns (b, (SetStyle a c)) = (b, (SetStyle a (snd(processIns (b, c)))))
            processIns (b, (SetColour a c)) = (b, (SetColour a (snd(processIns (b, c)))))

retrace :: Instructions -> Instructions
retrace i = rev i Stop True white (Solid 1)
          where
          rev :: Instructions -> Instructions -> Bool -> Colour -> LineStyle -> Instructions
          rev Stop i2 b c l = i2 `andThen` (PenDown Stop) `andThen` (SetColour white Stop) `andThen` (SetStyle (Solid 1) Stop)
          rev (PenUp a) i2 b c l | b == True = rev a ((PenDown Stop) `andThen` i2) False c l
                                 | b == False = rev a ((PenUp Stop) `andThen` i2) False c l
          rev (PenDown a) i2 b c l | b == True = rev a ((PenDown Stop) `andThen` i2) True c l
                                   | b == False = rev a ((PenUp Stop) `andThen` i2) True c l
          rev (Move a b) i2 c d e | c == True = rev b (((PenUp Stop) `andThen` (Move (-a) Stop) 
                                            `andThen` (PenDown Stop) `andThen` (Move a Stop) 
                                            `andThen` (PenUp Stop) `andThen` (Move (-a) Stop) 
                                            `andThen` (PenDown Stop) `andThen` i2 )) c d e
                                  | c == False = rev b ((Move (-a) Stop) `andThen` i2) c d e
          rev (Turn a b) i2 c d e = rev b ((Turn (-a) Stop) `andThen` i2) c d e
          rev (SetColour a b) i2 c d e = rev b ((SetColour d Stop) `andThen` i2) c a e
          rev (SetStyle a b) i2 c d e = rev b ((SetStyle e Stop) `andThen` i2) c d a

overlay :: [Instructions] -> Instructions
overlay [] = Stop
overlay (x:xs) =  x `andThen` (invisibly (retrace x)) `andThen` (overlay xs)
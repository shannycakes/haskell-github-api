module JsonParsing where 

import Char
import Safe
import Text.ParserCombinators.Parsec.Error
import Data.JSON2
import Data.JSON2.Parser
import Data.JSON2.Query
import Control.Applicative ((<$>))

data GitHubKey = Key {
  key :: String,
  title :: String,
  id :: Int
  } deriving (Show)

-- printRequest :: String -> String -> IO()
-- printRequest "" jsonres = putStrLn resultat
--   where resultat = case parseJson jsonres of
--           Left e -> show e
--           Right p -> case getFromArr p of
--             [] -> pprint p
--             tab@(x:_) -> concat (fmap pprint tab)
--             r -> pprint r -- concat (pprint <$> p)
-- printRequest key jsonres = putStrLn ((map toUpper key) ++ ":" ++ "\n" ++ printedValues)
--   where printedValues = case parseJson jsonres of
--           Left e -> show e
--           Right p -> case (getFromArr p) of
--               [] -> pprint (getFromKey key p)
--               tab@(x:_) ->  concat (displayValues . (getFromKey key) <$> tab)
--               r -> pprint (getFromKey key p)
              
getStrVal :: String -> String -> [String]
getStrVal key jsonres = case parseJson jsonres of
          Left e -> [show e]
          Right p 
            | ((getFromArr p) == []) && (key == "") -> [pprint p]     -- pas tab, pas k
            | ((getFromArr p) == []) -> pprint <$> (getFromKey key p) -- pas tab,  k
            | key == "" -> map (suppressApostroph . pprint) (getFromArr p)                 -- tab, pas k
            | otherwise -> (suppressApostroph . pprint) <$> (concat ((getFromKey key) <$> tab)) --tab, k
            where tab = getFromArr p

-- temporary solution until I master regex in Haskell
suppressApostroph :: String -> String 
suppressApostroph s 
  | (head s == '\"') && (last s == '\"') = init (tail s)  
  | otherwise = s
  
jsonToKeys :: String -> [GitHubKey]
jsonToKeys jsonres = case parseJson jsonres of
  Left e -> [Key "" "" (-1)]
  Right p 
    | (isArr p) == [] -> [createAKeyFromJson p]
    | otherwise -> map createAKeyFromJson (getFromArr p)
      where createAKeyFromJson j = Key 
                                   (readValue "key" j)
                                   (readValue "title" j) 
                                   (read (readValue "id" j)::Int) 
                                     where readValue s js =  (getFromKey s js) >>= pprint
                                 --where readValue = pprint . head . getFromKey

-- displayTuples :: [(String,Json)] -> String
-- displayTuples [] = ""
-- displayTuples ((k,v):ts) = (map toUpper k) ++ ":" ++ (pprint v) ++ "\n" ++ displayTuples ts  
-- displayValues :: [Json] -> String
-- displayValues = foldr (\ x a -> (pprint x) ++ "\n" ++ a) ""

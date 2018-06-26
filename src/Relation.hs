module Relation where

import Data.Hashable (Hashable)
import qualified Data.HashMap.Strict as M
import qualified Data.HashSet as S


type Relation a = [(a, a)] 
type SetRelation a = M.HashMap a (S.HashSet a)

reflexiveClosure :: (Eq a, Hashable a) => SetRelation a -> SetRelation a
reflexiveClosure = M.mapWithKey S.insert

transitiveClosure :: (Eq a, Hashable a) => Relation a -> SetRelation a
transitiveClosure = go <*> reflexiveClosure . toSet
  where go [] r = r 
        go ((a, b):abs) r = 
          case (M.lookup a r, M.lookup b r) of
            (_, Nothing) -> go abs r
            (Nothing, Just cs) -> go ([(a, c) | c <- S.toList cs] ++ abs) 
                                     (M.insert a cs r)
            (Just as, Just cs) -> go ([(a, c) | c <- S.toList (cs `S.difference` as)] ++ abs) 
                                     (M.insert a (as `S.union` cs) r)

toSet :: (Eq a, Hashable a) => Relation a -> SetRelation a
toSet = M.fromListWith S.union . map (\(x, y) -> (x, S.singleton y))

fromSet :: (Eq a, Hashable a) => SetRelation a -> Relation a
fromSet = concatMap (\(x, s) -> [(x, y) | y <- S.toList s]) . M.toList

lift :: (Eq a, Hashable a) => SetRelation a -> a -> S.HashSet a
lift r = maybe S.empty id . (`M.lookup` r)

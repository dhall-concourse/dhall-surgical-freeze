{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecordWildCards #-}

module Freeze.Lib where

import qualified Data.Map.Strict as Map
import qualified Data.Text as Text
import Dhall.Core
import Dhall.Parser
import System.FilePath ((</>))

findLocalDeps :: FilePath -> Expr Src Import -> [FilePath]
findLocalDeps selfPath =
  foldMap
    ( \(Import (ImportHashed _hash importType_) _) ->
        case importType_ of
          Local prefix file_ -> [makeAbsolute selfPath prefix file_]
          _ -> []
    )

makeAbsolute :: FilePath -> FilePrefix -> File -> FilePath
makeAbsolute selfPath prefix depFile =
  let File {..} = depFile
      Directory {..} = directory
      prefixPath = case prefix of
        Home -> "~"
        Absolute -> "/"
        Parent -> selfPath </> ".."
        Here -> selfPath
      cs = map Text.unpack (file : components)
      cons component dir = dir </> component
   in foldr cons prefixPath cs

reverseDeps :: [(FilePath, [FilePath])] -> [(FilePath, [FilePath])]
reverseDeps xs =
  let m = Map.fromList xs
      mInv = Map.foldrWithKey (Map.insertWith (<>)) Map.empty m
   in Map.toList mInv

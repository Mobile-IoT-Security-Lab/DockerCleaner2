{-# LANGUAGE DeriveGeneric #-}
module BestPractice
  ( BestPractice(..)
  , loadBestPractices
  ) where

import GHC.Generics            (Generic)
import qualified Data.ByteString.Lazy  as BL
import           Data.Csv              (FromNamedRecord, decodeByName, (.:), (.:?))
import qualified Data.Csv              as Csv
import qualified Data.Vector           as V

data BestPractice = BestPractice
  { bpID          :: !Int
  , bpName        :: !String
  , bpCategory    :: !String
  , bpDescription :: !String
  , bpBadExample  :: !(Maybe String)
  , bpGoodExample :: !(Maybe String)
  , bpSource      :: !(Maybe String)
  } deriving (Show, Generic)

instance FromNamedRecord BestPractice where
  parseNamedRecord m = BestPractice
    <$> m .:  "ID"
    <*> m .:  "Best Practice"
    <*> m .:  "Category"
    <*> m .:  "Description"
    <*> m .:? "Bad example"
    <*> m .:? "Good example"
    <*> m .:? "Source"

-- | Load the CSV shipped with the package.
loadBestPractices :: FilePath -> IO [BestPractice]
loadBestPractices path = do
  csvData <- BL.readFile path
  case decodeByName csvData of
    Left err       -> fail $ "CSV parse error: " ++ err
    Right (_, vec) -> return (V.toList vec)

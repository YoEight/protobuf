{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.HUnit
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck
import Test.QuickCheck.Modifiers

import GHC.Generics (Generic)

import Control.Applicative
import qualified Data.ByteString as B
import Data.ProtocolBuffers
import Data.ProtocolBuffers.Internal
import Data.Int
import Data.List
import Data.Monoid
import Data.Serialize
import Data.Word
import Data.TypeLevel.Num (Nat, reifyIntegral)

main :: IO ()
main = defaultMain tests

tests =
  [ testGroup "Single Values" singleValueTests
  ]

singleValueTests =
  [ testProperty "Int32"  prop_int32
  , testProperty "Int64"  prop_int64
  , testProperty "Word32" prop_word32
  , testProperty "Word64" prop_word64
  , testProperty "Float"  prop_float
  , testProperty "Double" prop_double
  ]

data OneValue n a = OneValue (Required n (Last a))
  deriving (Eq, Generic)

instance (EncodeWire a, Nat n) => Encode (OneValue n a)
instance (DecodeWire a, Nat n) => Decode (OneValue n a)

prop_roundtrip :: (Eq a, Nat n, Encode (OneValue n a), Decode (OneValue n a)) => OneValue n a -> Gen Bool
prop_roundtrip msg = do
  let bs = runPut $ encodeMessage msg
  case runGet decodeMessage bs of
    Right msg' -> return $ msg == msg'
    Left err   -> fail err

prop_reify :: forall a r . NonNegative Int32 -> Last a -> (forall n . Nat n => OneValue n a -> r) -> r
prop_reify (NonNegative n) a f = reifyIntegral n g where
  g :: forall n . Nat n => n -> r
  g _ = f (OneValue (putValue a) :: OneValue n a)

prop_word32 :: Gen Bool
prop_word32 = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Word32) prop_roundtrip

prop_word64 :: Gen Bool
prop_word64 = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Word64) prop_roundtrip

prop_int32 :: Gen Bool
prop_int32 = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Int32) prop_roundtrip

prop_int64 :: Gen Bool
prop_int64 = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Int64) prop_roundtrip

prop_float = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Float) prop_roundtrip

prop_double = do
  val <- Last . Just <$> arbitrary
  n <- arbitrary
  prop_reify n (val :: Last Double) prop_roundtrip
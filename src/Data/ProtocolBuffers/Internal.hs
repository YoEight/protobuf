module Data.ProtocolBuffers.Internal
  ( Tag
  , WireField(..)
  , wireFieldTag
  , getWireField
  , EncodeWire(..)
  , DecodeWire(..)
  , zzEncode32
  , zzEncode64
  , zzDecode32
  , zzDecode64
  , Field(..)
  , Value(..)
  ) where

import Data.ProtocolBuffers.Types
import Data.ProtocolBuffers.Wire

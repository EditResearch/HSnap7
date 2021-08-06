--{-# LANGUAGE InstanceSigs #-}

module Main where

import qualified PLC
import qualified Client as Cli


data DBInterface =
  DBInterface
    {bit1         :: Bool
    , bit2        :: Bool
    , bit3        :: Bool
    , label       :: String
    , labelShort  :: String
    , datetime    :: PLC.DTL
    , currentTime :: Int
    , pival       :: Float
    , counter     :: Int
    , idv         :: Int
    , model       :: Char}
      deriving (Show)


instance PLC.S7DB DBInterface where
  readFromDB db = do
    vbit1 <- PLC.readBool db 0 0
    vbit2 <- PLC.readBool db 0 1
    vbit3 <- PLC.readBool db 0 2
    vlabel <- PLC.readString db 2
    vlabelShort <- PLC.readString db 258
    vdateTime <- PLC.readDTL db 292
    vcurrentTime <- PLC.readDInt db 304
    vpi <- PLC.readReal db 308
    vcounter <- PLC.readInt db 312
    vid     <- PLC.readDInt db 314
    vmodel  <- PLC.readChar db 318

    return (DBInterface
              vbit1
              vbit2
              vbit3
              vlabel
              vlabelShort
              vdateTime
              vcurrentTime
              vpi
              vcounter
              vid
              vmodel)

  writeToDB self db = do
    PLC.writeBool db 0 0 (bit1 self)
    PLC.writeBool db 0 1 (bit2 self)
    PLC.writeBool db 0 2 (bit3 self)
    PLC.writeString db 2 254 (label self)
    PLC.writeString db 258 32 (labelShort self)
    PLC.writeDTL db 292 (datetime self)
    PLC.writeDInt db 304 (currentTime self)
    PLC.writeReal db 308 (pival self)
    PLC.writeInt db 312 (counter self)
    PLC.writeDInt db 314 (idv self)
    PLC.writeChar db 318 (model self)


process :: PLC.S7 -> IO ()
process client = do
  db <- Cli.readData 1 0 319 client :: IO (Maybe DBInterface)
  let update = DBInterface
                        True
                        True
                        True
                        "Hello world"
                        "Short"
                        (PLC.DTL 1975 12 2 3 13 30 1 455)
                        123245
                        2.753
                        123
                        122
                        'H'

  ret <- Cli.writeData update 1 0 319 client
  print ret
  print db


main :: IO()
main = do
    Cli.withS7Client "192.168.2.1" 0 1 process

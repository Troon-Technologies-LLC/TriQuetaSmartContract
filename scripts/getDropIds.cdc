import TriQueta from "./TriQueta.cdc"

pub fun main(): [UInt64]{
   return  TriQueta.getAllDrops().keys
}
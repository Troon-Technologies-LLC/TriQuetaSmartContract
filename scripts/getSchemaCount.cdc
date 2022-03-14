import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"

// Print the Collection owned by accounts 0x01
pub fun main() : Int {
  return  TriQuetaNFT.getAllSchemas().length
}

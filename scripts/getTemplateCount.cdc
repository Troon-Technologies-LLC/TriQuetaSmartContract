import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"

pub fun main() : Int {
  return  TriQuetaNFT.getAllTemplates().length
}
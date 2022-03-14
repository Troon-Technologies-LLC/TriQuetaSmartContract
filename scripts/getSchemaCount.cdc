import TriQuetaNFT from 0x3a57788afdda9ea7

// Print the Collection owned by accounts 0x01
pub fun main() : Int {
  return  TriQuetaNFT.getAllSchemas().length
}

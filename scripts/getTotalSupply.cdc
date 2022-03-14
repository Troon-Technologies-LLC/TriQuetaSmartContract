import TriQuetaNFT from "./TriQuetaNFT.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

pub fun main(): UInt64 {
    return TriQuetaNFT.totalSupply
}
import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

pub fun main(nftId: UInt64) : AnyStruct{    
    var nftData = TriQuetaNFT.getNFTDataById(nftId: nftId)
    return nftData
}
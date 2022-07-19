import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20


pub fun main(address: Address):[UInt64]{
    let account1 = getAccount(address)
    let acct1Capability =  account1.getCapability(TriQuetaNFT.CollectionPublicPath)
                           .borrow<&{TriQuetaNFT.NFTContractCollectionPublic}>()
                            ??panic("could not borrow receiver Reference ")
    return acct1Capability.getIDs()
}
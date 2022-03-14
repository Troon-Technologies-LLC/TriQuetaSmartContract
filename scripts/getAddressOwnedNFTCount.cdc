import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20

// Print the NFTs owned by accounts 0x01 and 0x02.
pub fun main(address: Address): Int {

    // Get both public account objects
     let account1 = getAccount(address)
    // Find the public Receiver capability for their Collections
    let acct1Capability =  account1.getCapability(TriQuetaNFT.CollectionPublicPath)
                           .borrow<&{TriQuetaNFT.TriQuetaNFTContractCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")

    return  acct1Capability.getIDs().length
}
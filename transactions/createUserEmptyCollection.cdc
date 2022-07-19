import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20
transaction {
    prepare(acct: AuthAccount) {

        let collection  <- TriQuetaNFT.createEmptyCollection()
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:TriQuetaNFT.CollectionStoragePath)
        log("Collection created for account".concat(acct.address.toString()))
        // create a public capability for the Collection
        acct.link<&{TriQuetaNFT.NFTContractCollectionPublic}>(TriQuetaNFT.CollectionPublicPath, target:TriQuetaNFT.CollectionStoragePath)
        log("Capability created")

    }
}

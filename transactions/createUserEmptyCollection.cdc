import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
import NonFungibleToken from 0xf8d6e0586b0a20c7
transaction {
    prepare(acct: AuthAccount) {

        let collection  <- TriQuetaNFT.createEmptyCollection()
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:TriQuetaNFT.CollectionStoragePath)
        log("Collection created for account".concat(acct.address.toString()))
        // create a public capability for the Collection
        acct.link<&{NonFungibleToken.CollectionPublic}>(TriQuetaNFT.CollectionPublicPath, target:TriQuetaNFT.CollectionStoragePath)
        log("Capability created")

    }
}

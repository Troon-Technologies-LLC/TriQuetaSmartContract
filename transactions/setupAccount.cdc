import TriQuetaNFT from "./TriQuetaNFT.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction {
    prepare(acct: AuthAccount) {
        let collection  <- TriQuetaNFT.createEmptyCollection()
        // store the empty NFT Collection in account storage
        acct.save( <- collection, to:TriQuetaNFT.CollectionStoragePath)
        // create a public capability for the Collection
        acct.link<&{NonFungibleToken.CollectionPublic}>(TriQuetaNFT.CollectionPublicPath, target: TriQuetaNFT.CollectionStoragePath)
    }
}
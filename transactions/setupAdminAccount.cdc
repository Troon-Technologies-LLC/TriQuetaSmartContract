import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        // save the resource to the signer's account storage
        if signer.getLinkTarget(TriQuetaNFT.NFTMethodsCapabilityPrivatePath) == nil {
            let adminResouce <- TriQuetaNFT.createAdminResource()
            signer.save(<- adminResouce, to: TriQuetaNFT.AdminResourceStoragePath)
            // link the UnlockedCapability in private storage
            signer.link<&{TriQuetaNFT.NFTMethodsCapability}>(
                TriQuetaNFT.NFTMethodsCapabilityPrivatePath,
                target: TriQuetaNFT.AdminResourceStoragePath
            )
        }

        signer.link<&{TriQuetaNFT.UserSpecialCapability}>(
            /public/UserSpecialCapability,
            target: TriQuetaNFT.AdminResourceStoragePath
        )

        let collection  <- TriQuetaNFT.createEmptyCollection()
        // store the empty NFT Collection in account storage
        signer.save( <- collection, to: TriQuetaNFT.CollectionStoragePath)
        // create a public capability for the Collection
        signer.link<&{NonFungibleToken.CollectionPublic}>(TriQuetaNFT.CollectionPublicPath, target:TriQuetaNFT.CollectionStoragePath)
        log("ok")
    }
}
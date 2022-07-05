import TriQuetaNFT from 0x3a57788afdda9ea7
transaction(brandId: UInt64, schemaId: UInt64, maxSupply: UInt64) {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")
        let extra: {String: AnyStruct} = {
                "name" : "alex"       
        }
        
        let immutableData: {String: AnyStruct} = {
            "artist" : "Nasir And Sham",
            "artistEmail" : "sham&nasir@gmai.com",
            "title" : "First NFT",
            "mintType" : "MintOnSale",
            "nftType" : "AR",
            "rarity" : "Epic",
            "contectType" : "Image",
            "contectValue" : "https://troontechnologies.com/",
            "extras" : extra        
        }
        actorResource.createTemplate(brandId: brandId, schemaId: schemaId, maxSupply: maxSupply, immutableData: immutableData, mutableData: nil)
        log("ok")
    }
}
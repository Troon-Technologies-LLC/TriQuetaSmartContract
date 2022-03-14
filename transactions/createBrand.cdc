import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
transaction (brandName: String, data: {String:String}){
    prepare(acct: AuthAccount) {
    
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")

        actorResource.createNewBrand(
         brandName: brandName,
        data: data)
        log("ok")
    }
}
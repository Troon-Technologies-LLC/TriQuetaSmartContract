import TriQuetaNFT from 0x3a57788afdda9ea7
transaction(brandId: UInt64, schemaId: UInt64, maxSupply: UInt64, immutableData:{String: AnyStruct}) {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")
             let extra: {String: AnyStruct} = {
                "name" : "alex", // string
                "age" : 21,// integer
                "percentage" : 2.1 as Fix64, // address
                "owner" : 0x01 as Address, // bool
                "burnable" : false,
                "startDate" : "",
                "endDate" : ""             
        }
     
        actorResource.createTemplate(brandId: brandId, schemaId: schemaId, maxSupply: maxSupply, immutableData: immutableData)
        log("ok")
    }
}
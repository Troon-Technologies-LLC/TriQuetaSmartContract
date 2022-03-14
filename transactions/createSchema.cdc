import TriQuetaNFT from 0x3a57788afdda9ea7
transaction (){
// schemaName:String
   prepare(acct: AuthAccount) {
      let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")

         let format : {String: TriQuetaNFT.SchemaType} = {
            "artist" : TriQuetaNFT.SchemaType.String,
            "artistEmail"  :  TriQuetaNFT.SchemaType.String,
            "title":TriQuetaNFT.SchemaType.String,
            "mintType":  TriQuetaNFT.SchemaType.String,
            "nftType":  TriQuetaNFT.SchemaType.String,
            "rarity":  TriQuetaNFT.SchemaType.String,
            "contectType":  TriQuetaNFT.SchemaType.String,
            "contectValue":  TriQuetaNFT.SchemaType.String,
            "extras": TriQuetaNFT.SchemaType.Any
            }
         actorResource.createSchema(schemaName: "nft-series", format: format)
         log("ok")
   }
}
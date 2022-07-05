import TriQuetaNFT from 0x118cabc98306f7d1
transaction (schemaName: String){
// schemaName:String
   prepare(acct: AuthAccount) {
      let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")

         let format : {String: TriQuetaNFT.SchemaType} = {
            "artist": TriQuetaNFT.SchemaType.String,
            "artistEmail":  TriQuetaNFT.SchemaType.String,
            "title":  TriQuetaNFT.SchemaType.String,
            "mintType":  TriQuetaNFT.SchemaType.String,
            "nftType":  TriQuetaNFT.SchemaType.String,
            "rarity":  TriQuetaNFT.SchemaType.String,
            "contectType":  TriQuetaNFT.SchemaType.String,
            "contectValue":  TriQuetaNFT.SchemaType.String,
            "extras": TriQuetaNFT.SchemaType.Any
            }
         actorResource.createSchema(schemaName: schemaName, format: format)
         log("ok")
   }
}
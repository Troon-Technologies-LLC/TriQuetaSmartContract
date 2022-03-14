import TriQuetaNFT from "./TriQuetaNFT.cdc"

transaction (brandId: UInt64, brandName: String){
  prepare(acct: AuthAccount) {

    let actorResource = acct.getCapability
              <&{TriQuetaNFT.NFTMethodsCapability}>
              (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
              .borrow() ?? 
              panic("could not borrow a reference to the NFTMethodsCapability interface")

    actorResource.updateBrandData(
    brandId: brandId,
    data:  {
        "brandName": brandName
      })
  }
}
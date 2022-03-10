import NFTContract from "./NFTContract.cdc"

transaction (brandId: UInt64, brandName: String){
  prepare(acct: AuthAccount) {

    let actorResource = acct.getCapability
              <&{NFTContract.NFTMethodsCapability}>
              (NFTContract.NFTMethodsCapabilityPrivatePath)
              .borrow() ?? 
              panic("could not borrow a reference to the NFTMethodsCapability interface")

    actorResource.updateBrandData(
    brandId: brandId,
    data:  {
        "brandName": brandName
      })
  }
}
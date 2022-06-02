import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"


transaction (templateId:UInt64){
  prepare(acct: AuthAccount) {

     let actorResource = acct.getCapability
              <&{TriQuetaNFT.NFTMethodsCapability}>
              (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
              .borrow() ?? 
              panic("could not borrow a reference to the NFTMethodsCapability interface")

             
        var key = "game"
        var value = "cricket"

    actorResource.updateTemplateMutableAttribute(templateId: templateId, key: key, value: value)

  }
}
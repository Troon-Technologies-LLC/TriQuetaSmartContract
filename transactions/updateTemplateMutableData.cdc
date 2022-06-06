import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"


transaction (templateId:UInt64){
  prepare(acct: AuthAccount) {

     let actorResource = acct.getCapability
              <&{TriQuetaNFT.NFTMethodsCapability}>
              (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
              .borrow() ?? 
              panic("could not borrow a reference to the NFTMethodsCapability interface")

             let mutableData : {String: AnyStruct} = {
                "Keyboard" : "Qwerty",
                "InputType" : "AlphaNumeric"
              
             }

    actorResource.updateTemplateMutableData(templateId: templateId, mutableData: mutableData)

  }
}
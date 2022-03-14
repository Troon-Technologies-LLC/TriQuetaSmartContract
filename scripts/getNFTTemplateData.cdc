import TriQuetaNFT from "./TriQuetaNFT.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

pub fun main(address: Address) : {UInt64: AnyStruct}{
    let account1 = getAccount(address)
    let acct1Capability =  account1.getCapability(TriQuetaNFT.CollectionPublicPath)
                            .borrow<&{NonFungibleToken.CollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    var nftIds =   acct1Capability.getIDs()
    var dict : {UInt64: AnyStruct} = {}
    for nftId in nftIds {
        var nftData = TriQuetaNFT.getNFTDataById(nftId: nftId)
        var templateDataById =  TriQuetaNFT.getTemplateById(templateId: nftData.templateID)
        var nftMetaData : {String:AnyStruct} = {}
        
        nftMetaData["mintNumber"] =nftData.mintNumber;
        nftMetaData["templateData"] = templateDataById;
        dict.insert(key: nftId,nftMetaData)
    }
    return dict
}
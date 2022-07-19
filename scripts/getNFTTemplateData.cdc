import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20
pub fun main(address: Address) : {UInt64: AnyStruct}{
    let account1 = getAccount(address)
    let acct1Capability =  account1.getCapability(TriQuetaNFT.CollectionPublicPath)
                            .borrow<&{TriQuetaNFT.NFTContractCollectionPublic}>()
                            ??panic("could not borrow receiver reference ")
    var nftIds =   acct1Capability.getIDs()
    var dict : {UInt64: AnyStruct} = {}
    for nftId in nftIds {
        var nftData = TriQuetaNFT.getNFTDataById(nftId: nftId)
        var templateDataById =  TriQuetaNFT.getTemplateById(templateId: nftData.templateID)
        var nftMetaData : {String:AnyStruct} = {}
        
        nftMetaData["mintNumber"] =  nftData.mintNumber;
        nftMetaData["templateData"] = templateDataById;
        dict.insert(key: nftId,nftMetaData)
    }
    return dict
}
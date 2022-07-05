import TriQuetaNFT from 0x3a57788afdda9ea7
import TriQueta from 0xc864a46475249419

pub fun main(dropId: UInt64):{String:UInt64}{

    let outdropId = TriQueta.getDropById(dropId: dropId)
    let templateid = outdropId.getDropTemplates().keys

    let getTemplate = TriQuetaNFT.getTemplateById(templateId: templateid[0])
    let issuedSupply = getTemplate.issuedSupply

    let maxSupply = getTemplate.maxSupply


    var dropMetaData: {String:UInt64}= {}
    
        dropMetaData["IssuedSupply"] = getTemplate.issuedSupply
        dropMetaData["MaxSupply"] =  getTemplate.maxSupply


    return  dropMetaData

}
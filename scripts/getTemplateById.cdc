import NFTContract from "./NFTContract.cdc"

pub fun main(templateId: UInt64): NFTContract.Template {
    return NFTContract.getTemplateById(templateId: templateId)
}
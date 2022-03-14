import TriQuetaNFT from "./TriQuetaNFT.cdc"

pub fun main(templateId: UInt64): TriQuetaNFT.Template {
    return TriQuetaNFT.getTemplateById(templateId: templateId)
}
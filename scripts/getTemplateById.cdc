import TriQuetaNFT from 0x3a57788afdda9ea7

pub fun main(templateId: UInt64): TriQuetaNFT.Template {
    return TriQuetaNFT.getTemplateById(templateId: templateId)
}
import TriQuetaNFT from 0x118cabc98306f7d1

pub fun main(templateId: UInt64): Bool {
    return TriQuetaNFT.isTemplateLocked(templateId: templateId)
}
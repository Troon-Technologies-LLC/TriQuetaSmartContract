import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"

pub fun main(templateId:UInt64): {String:AnyStruct} {
    return TriQuetaNFT.getImmutableData(templateId: templateId)
}
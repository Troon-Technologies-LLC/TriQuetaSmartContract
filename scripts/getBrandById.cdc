import TriQuetaNFT from "./TriQuetaNFT.cdc"
pub fun main(brandId:UInt64): AnyStruct{
    return TriQuetaNFT.getBrandById(brandId: brandId)
}
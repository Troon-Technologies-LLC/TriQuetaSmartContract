import TriQuetaNFT from 0x3a57788afdda9ea7
pub fun main(brandId:UInt64): AnyStruct{
    return TriQuetaNFT.getBrandById(brandId: brandId)
}
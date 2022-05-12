
import TriQuetaNFT from 0x3a57788afdda9ea7

pub fun main(brandId:UInt64): TriQuetaNFT.Brand {
    return TriQuetaNFT.getBrandById(brandId: brandId)
}
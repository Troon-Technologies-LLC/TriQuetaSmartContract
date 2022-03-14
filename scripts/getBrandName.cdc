
import TriQuetaNFT from "../contracts/TriQuetaNFT.cdc"

pub fun main(brandId:UInt64): TriQuetaNFT.Brand {
    return TriQuetaNFT.getBrandById(brandId: brandId)
}
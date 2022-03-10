
import NFTContract from "../contracts/NFTContract.cdc"

pub fun main(brandId:UInt64): NFTContract.Brand {
    return NFTContract.getBrandById(brandId: brandId)
}
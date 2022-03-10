import NFTContract from "./NFTContract.cdc"
pub fun main(): {UInt64:NFTContract.Brand} {
    return NFTContract.getAllBrands()

}
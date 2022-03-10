import NFTContract from "./NFTContract.cdc"

pub fun main(): {UInt64:NFTContract.Schema} {
    return NFTContract.getAllSchemas()

}
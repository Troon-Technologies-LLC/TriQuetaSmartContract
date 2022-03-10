import NFTContract from "./NFTContract.cdc"

pub fun main():{UInt64:NFTContract.Template}  {
    return NFTContract.getAllTemplates()
}

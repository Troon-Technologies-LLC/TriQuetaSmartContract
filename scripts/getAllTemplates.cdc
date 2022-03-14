import TriQuetaNFT from "./TriQuetaNFT.cdc"

pub fun main():{UInt64:TriQuetaNFT.Template}  {
    return TriQuetaNFT.getAllTemplates()
}

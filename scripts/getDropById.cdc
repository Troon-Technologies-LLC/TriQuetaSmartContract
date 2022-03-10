import TriQueta from "./TriQueta.cdc"

pub fun main(dropId: UInt64):TriQueta.Drop {
    return  TriQueta.getDropById(dropId: dropId)
    
}
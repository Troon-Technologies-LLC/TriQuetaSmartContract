import TriQueta from 0xc864a46475249419
pub fun main(dropId: UInt64):TriQueta.Drop {
    return  TriQueta.getDropById(dropId: dropId)
    
}
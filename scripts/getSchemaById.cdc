import TriQuetaNFT from "./TriQuetaNFT.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

pub fun main(schemaId: UInt64): TriQuetaNFT.Schema {
    return TriQuetaNFT.getSchemaById(schemaId: schemaId)
}
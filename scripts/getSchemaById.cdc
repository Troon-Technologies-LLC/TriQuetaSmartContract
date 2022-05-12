import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20

pub fun main(schemaId: UInt64): TriQuetaNFT.Schema {
    return TriQuetaNFT.getSchemaById(schemaId: schemaId)
}
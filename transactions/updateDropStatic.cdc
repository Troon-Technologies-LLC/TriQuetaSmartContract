import TriQueta from "../contracts/TriQueta.cdc"

transaction(DropId: UInt64, StartDate: UFix64?,EndDate: UFix64?){
    let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
    }
    execute{
         //let template : {UInt64:AnyStruct} = {3:"3"}
         //let template : {UInt64:AnyStruct} = {}
        self.adminRef.updateDrop(dropId: DropId, startDate: StartDate, endDate: EndDate, templates: nil)
        
    }
}

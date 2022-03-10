import TriQueta from "../contracts/TriQueta.cdc"

transaction(DropId: UInt64, StartDate: UFix64,EndDate: UFix64,template: {UInt64:AnyStruct}){
    let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
    }
    execute{
        self.adminRef.createDrop(dropId: DropId, startDate: StartDate, endDate: EndDate, templates: template)
        
        
        log("ok")
    }
}
import TriQueta from "./TriQueta.cdc"

transaction(DropId: UInt64){
   let adminRef: &TriQueta.DropAdmin
   prepare(acct: AuthAccount) {
      self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
      ??panic("could not borrow refrence")
   }
   
   execute{
      self.adminRef.removeDrop(dropId: DropId)
   }
}
import TriQueta from 0xc864a46475249419

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
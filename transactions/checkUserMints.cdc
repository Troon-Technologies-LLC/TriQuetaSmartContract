import TriQueta from "../contracts/TriQueta.cdc"

transaction {
   let adminRef: &TriQueta.DropAdmin
  prepare(acct: AuthAccount) {
    self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
  }

  execute {
    let data = self.adminRef.getUserMints(dropId: 1, receiptAddress: 0x01)
    if data == false {
        panic("user does not have reserved mints")
    }
  }
}

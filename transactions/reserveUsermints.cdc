import TriQueta from "../contracts/TriQueta.cdc"

transaction {
   let adminRef: &TriQueta.DropAdmin
  prepare(acct: AuthAccount) {
    self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
  }

  execute {
    self.adminRef.ReserveUserNFT(dropId: 1, templateId:1, receiptAddress: 0x01, mintNumbers: 1)
  }
}

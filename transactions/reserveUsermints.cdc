import TriQueta from 0xc864a46475249419
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

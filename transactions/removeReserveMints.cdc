import TriQueta from 0xc864a46475249419

transaction (DropId: UInt64, Creator: Address, mintNumbers: UInt64){
   let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
            ??panic("could not borrow admin reference")
    }

    execute {
        self.adminRef.removeReservedUserNFT(dropId: DropId, receiptAddress: Creator, mintNumbers: mintNumbers)
    }
}

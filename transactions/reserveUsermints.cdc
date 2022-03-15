import TriQueta from 0xc864a46475249419
transaction(DropId: UInt64,TemplateId: UInt64, Creator: Address,MintNumber: UInt64){
    let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from: TriQueta.DropAdminStoragePath)
                        ??panic("could not borrow admin reference")
    }
    execute {
        self.adminRef.ReserveUserNFT(dropId: DropId, templateId:TemplateId, receiptAddress: Creator, mintNumbers: MintNumber)
    }
}

import TriQueta from 0xe175fb8178dc39c3

transaction(DropId: UInt64,TemplateId: UInt64,MintNumber: UInt64,Creator: Address, immutableData:{String:AnyStruct}?) {
    let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from:TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
    
    self.adminRef.purchaseNFT(dropId: DropId, templateId: TemplateId, mintNumbers: MintNumber, receiptAddress: Creator, immutableData: immutableData)
    }
}
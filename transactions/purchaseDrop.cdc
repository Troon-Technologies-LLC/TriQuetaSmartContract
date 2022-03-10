import TriQueta from "./TriQueta.cdc"

transaction(DropId: UInt64,TemplateId: UInt64,MintNumber: UInt64,Creator: Address) {
    let adminRef: &TriQueta.DropAdmin
    prepare(acct: AuthAccount) {
        self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from:TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
    
    self.adminRef.purchaseNFT(dropId: DropId, templateId: TemplateId, mintNumbers: MintNumber, receiptAddress: Creator)
    }
}
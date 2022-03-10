import TriQueta from "./TriQueta.cdc"
import FungibleToken from 0xee82856bf20e2aa6 // emulator address
import FlowToken from 0x0ae53cb6e3f42a79  // emulator address

transaction(DropId: UInt64, TemplateId: UInt64, MintNumber: UInt64, receiptAddress: Address, Price: UFix64) {
    //it holds the reference to the owner
    let adminRef: &TriQueta.DropAdmin
    // Temporary Vault object that holds the balance that is being transferred
    var temporaryVault: @FungibleToken.Vault

    prepare(providerAccount: AuthAccount, tokenRecipientAccount:AuthAccount) {
        self.adminRef = providerAccount.borrow<&TriQueta.DropAdmin>(from:TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")
 
         let vaultRef = tokenRecipientAccount.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("Could not borrow buyer vault reference")
        self.temporaryVault <- vaultRef.withdraw(amount: Price)
    }
  
    execute{
      
      let dropResponse = self.adminRef.purchaseNFTWithFlow(dropId: DropId, templateId: TemplateId, mintNumbers: MintNumber, receiptAddress: receiptAddress, price:Price,flowPayment: <- self.temporaryVault)
      
      log(dropResponse)
    }
}

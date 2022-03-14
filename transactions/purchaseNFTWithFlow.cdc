import TriQueta from 0xc864a46475249419
import FungibleToken from  0x9a0766d93b6608b7 // testnet address
import FlowToken from 0x7e60df042a9c0868 // testnet address

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

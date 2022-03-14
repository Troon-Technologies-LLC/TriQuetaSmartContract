import TriQueta from 0xc864a46475249419
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868    

transaction {
    
    let adminRef: &TriQueta.DropAdmin

    prepare(acct: AuthAccount) {
       let data = acct.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

       self.adminRef = acct.borrow<&TriQueta.DropAdmin>(from:TriQueta.DropAdminStoragePath)
        ??panic("could not borrow admin reference")

       self.adminRef.addOwnerVault(_ownerVault: data)
    }

    execute{
        log("Vault capability added")
    }
}

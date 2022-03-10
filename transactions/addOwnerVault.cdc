import TriQueta from 0xf8d6e0586b0a20c7
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79    

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

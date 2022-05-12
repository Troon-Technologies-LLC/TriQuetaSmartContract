import TriQuetaNFT from 0x3a57788afdda9ea7

transaction (){
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")
    }
}
import TriQueta from 0x3a57788afdda9ea7
transaction(templateId: UInt64) {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQueta.NFTMethodsCapability}>
            (TriQueta.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")
     
        actorResource.removeTemplateById(templateId: templateId)
        log("ok")
    }
}
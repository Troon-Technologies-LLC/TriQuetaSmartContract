import TriQuetaNFT from 0x118cabc98306f7d1
transaction(templateId: UInt64, status: Bool) {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ?? 
            panic("could not borrow a reference to the NFTMethodsCapability interface")
     
        actorResource.lockTemplateById(templateId: templateId, status: status)
        log("ok")
    }
}
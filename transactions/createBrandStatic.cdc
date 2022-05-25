import TriQuetaNFT from 0x118cabc98306f7d1

transaction () {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ??
            panic("could not borrow a reference to the NFTMethodsCapability interface")
        actorResource.createNewBrand(
        brandName: "TriQueta",
        data: {
            "name":"TriQueta",
            "description":"TriQueta's goal is to provide professional E-Sport athletes with a platform on which they can monetize their content in the form of converting their epic gaming highlights to NFTs and selling them to their fans. Fans can collect their favorite E-Sport athlete's NFTs which will be verified with a limited original content variation.",
            "url":"https://triqueta.tech"
        })
        log("ok")
    }
}
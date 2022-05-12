import TriQuetaNFT from 0x3a57788afdda9ea7

transaction () {
    prepare(acct: AuthAccount) {
        let actorResource = acct.getCapability
            <&{TriQuetaNFT.NFTMethodsCapability}>
            (TriQuetaNFT.NFTMethodsCapabilityPrivatePath)
            .borrow() ??
            panic("could not borrow a reference to the NFTMethodsCapability interface")
        actorResource.createNewBrand(
        brandName: "TriQuetaNFT",
        data: {
            "name":"TriQuetaNFT",
            "description":"A two-sided blockchain-backed intelligent NFT marketplace with a 'NETFLIX-style' recommend engine - indexing / scoring and ranking assets - connecting Collectors with Creators and vice versa",
            "url":"https://troontechnologies.com/"
        })
        log("ok")
    }
}
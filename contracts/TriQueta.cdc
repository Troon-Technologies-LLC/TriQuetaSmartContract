import TriQuetaNFT from 0x3a57788afdda9ea7
import NonFungibleToken from 0x631e88ae7f1d7c20
import FungibleToken from  0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868

pub contract TriQueta {
    // -----------------------------------------------------------------------
    // TriQueta contract Event definitions
    // -----------------------------------------------------------------------
    pub event ContractInitialized()
    // Emitted when a new Drop is created
    pub event DropCreated(dropId: UInt64, creator: Address, startDate: UFix64, endDate: UFix64)
    // Emitted when a Drop is purchased
    pub event DropPurchased(dropId: UInt64, templateId: UInt64, mintNumbers: UInt64, receiptAddress: Address)
     // Emitted when a Drop is purchased using flow
    pub event DropPurchasedWithFlow(dropId: UInt64, templateId: UInt64, mintNumbers: UInt64, receiptAddress: Address, price: UFix64)
    // Emitted when a Drop is removed
    pub event DropRemoved(dropId: UInt64)
    // Emitted when a new Drop is created
    pub event DropUpdated(dropId: UInt64, creator: Address, startDate: UFix64, endDate: UFix64)
    // Emitted when a user mintNumber is reserved
    pub event MintNumberReserved(dropId: UInt64, receiptAddress: Address)
    // Contract level paths for storing resources
    pub let DropAdminStoragePath: StoragePath
    // The capability that is used for calling the admin functions 
    access(contract) let adminRef: Capability<&{TriQuetaNFT.NFTMethodsCapability}>
    // Variable size dictionary of Drop structs
    access(self) var allDrops: {UInt64: Drop}
    // the dictionary to store reserve user mints with address
    access(contract) var allReserved: {UInt64: {Address:RserveMints}}
    // the dictionary to store mints for drop
     access(contract) var reservedMints: {UInt64: UInt64}
    // -----------------------------------------------------------------------
    // TriQueta contract-level Composite Type definitions
    // -----------------------------------------------------------------------
    // These are just *definitions* for Types that this contract
    // and other accounts can use. These definitions do not contain
    // actual stored values, but an instance (or object) of one of these Types
    // can be created by this contract that contains stored values.

    // Drop is a struct 
    pub struct Drop {
        pub let dropId: UInt64
        pub var startDate: UFix64
        pub var endDate: UFix64
        pub var templates: {UInt64: AnyStruct}

        init(dropId: UInt64, startDate: UFix64, endDate: UFix64, templates: {UInt64: AnyStruct}) {
            self.dropId = dropId
            self.startDate = startDate
            self.endDate = endDate
            self.templates = templates
        }

        access(contract) fun updateDrop(startDate: UFix64, endDate: UFix64, templates: {UInt64: AnyStruct}) {
            self.startDate = startDate
            self.endDate = endDate
            self.templates = templates
        }
    }

    // RserveMints is a struct 
    pub struct RserveMints {
        pub let user_address: {String: UInt64}

        init(user_address: {String: UInt64}) {
            
            self.user_address = user_address
        }
        pub fun addUserMint(mintNumber: String, mintNumberValue :UInt64){
            self.user_address.insert(key: mintNumber, mintNumberValue)
        }
    }
    

    // DropAdmin
    // This is the main resource to manage the NFTs that they are creating and purchasing.
    pub resource DropAdmin {
        access(contract) var ownerVault: Capability<&AnyResource{FungibleToken.Receiver}>?

        pub fun addOwnerVault(_ownerVault: Capability<&AnyResource{FungibleToken.Receiver}>){
            self.ownerVault = _ownerVault
        }

        pub fun createDrop(dropId: UInt64, startDate: UFix64, endDate: UFix64, templates: {UInt64: AnyStruct}){
            pre{
                dropId != nil: "invalid drop id"
                TriQueta.allDrops[dropId] == nil: "drop id already exists"
                startDate >= getCurrentBlock().timestamp: "Start Date should be greater or Equal than current time"
                endDate > startDate: "End date should be greater than start date"
                templates != nil: "templates must not be null"
            }

            var areValidTemplates: Bool = true
            for templateId in templates.keys {
                var template = TriQuetaNFT.getTemplateById(templateId: templateId)
                if(template == nil){
                    areValidTemplates = false
                    break
                }
            }
            assert(areValidTemplates, message:"templateId is not valid")

            var newDrop = Drop(dropId: dropId,startDate: startDate, endDate: endDate, templates: templates)
            TriQueta.allDrops[newDrop.dropId] = newDrop

            emit DropCreated(dropId: dropId, creator: self.owner?.address!, startDate: startDate, endDate: endDate)
        }

        pub fun updateDrop(dropId: UInt64, startDate: UFix64, endDate: UFix64, templates: {UInt64: AnyStruct}){
            pre{
                dropId != nil: "invalid drop id"
                TriQueta.allDrops[dropId] != nil: "drop id does not exists"
                startDate >= getCurrentBlock().timestamp: "Start Date should be greater or Equal than current time"
                endDate > startDate: "End date should be greater than start date"
                templates != nil: "templates must not be null"
            }

            var areValidTemplates: Bool = true
            for templateId in templates.keys {
                var template = TriQuetaNFT.getTemplateById(templateId: templateId)
                if(template == nil){
                    areValidTemplates = false
                    break
                }
            }
            assert(areValidTemplates, message:"templateId is not valid")
            TriQueta.allDrops[dropId]!.updateDrop(startDate: startDate, endDate: endDate, templates: templates)

            emit DropUpdated(dropId: dropId, creator: self.owner?.address!, startDate: startDate, endDate: endDate)
        }

        pub fun removeDrop(dropId: UInt64){
            pre {
                dropId != nil : "invalid drop id"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                getCurrentBlock().timestamp < TriQueta.allDrops[dropId]!.startDate: "Drop sale is started"

            }

            TriQueta.allDrops.remove(key: dropId)
            emit DropRemoved(dropId: dropId)
        }

        pub fun purchaseNFT(dropId: UInt64,templateId: UInt64, mintNumbers: UInt64, receiptAddress: Address){
            pre {
                mintNumbers > 0: "mint number must be greater than zero"
                mintNumbers <= 10: "mint numbers must be less than ten"
                templateId > 0: "template id must be greater than zero"
                dropId != nil : "invalid drop id"
                receiptAddress !=nil: "invalid receipt Address"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                TriQueta.allDrops[dropId]!.startDate <= getCurrentBlock().timestamp: "drop not started yet"
                TriQueta.allDrops[dropId]!.endDate > getCurrentBlock().timestamp: "drop already ended"
                TriQueta.allDrops[dropId]!.templates[templateId] != nil: "template id does not exist"
                TriQueta.allReserved[dropId] != nil: "drop id does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress] != nil: "given address does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress]!.user_address["mintNumber"]! > 0: "mint for this address is not reserved"
            }

            var template = TriQuetaNFT.getTemplateById(templateId: templateId)
            assert(template.issuedSupply + mintNumbers <= template.maxSupply, message: "template reached to its max supply") 
            var i: UInt64 = 0
            while i < mintNumbers {
                TriQueta.adminRef.borrow()!.mintNFT(templateId: templateId, account: receiptAddress)
                i = i + 1
            }
            let mintsData = TriQueta.allReserved[dropId]![receiptAddress]!.user_address.remove(key: "mintNumber")
            let reserveData = TriQueta.allReserved[dropId]!.remove(key: receiptAddress)
            let mints = TriQueta.reservedMints[dropId]!
            TriQueta.reservedMints[dropId] = mints.saturatingSubtract(mintNumbers)

            emit DropPurchased(dropId: dropId,templateId: templateId, mintNumbers: mintNumbers, receiptAddress: receiptAddress)
        }

        pub fun purchaseNFTWithFlow(dropId: UInt64, templateId: UInt64, mintNumbers: UInt64, receiptAddress: Address, price: UFix64, flowPayment: @FungibleToken.Vault) {
            pre{
                price > 0.0: "Price should be greater than zero"
                receiptAddress !=nil: "invalid receipt Address"
                flowPayment.balance == price: "Your vault does not have balance to buy NFT"
                mintNumbers > 0: "mint number must be greater than zero"
                mintNumbers <= 10: "mint numbers must be less than ten"
                templateId > 0: "template id must be greater than zero"
                dropId != nil : "invalid drop id"
                receiptAddress !=nil: "invalid receipt Address"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                TriQueta.allDrops[dropId]!.startDate <= getCurrentBlock().timestamp: "drop not started yet"
                TriQueta.allDrops[dropId]!.endDate > getCurrentBlock().timestamp: "drop already ended"
                TriQueta.allDrops[dropId]!.templates[templateId] != nil: "template id does not exist"
                TriQueta.allReserved[dropId] != nil: "drop id does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress] != nil: "given address does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress]!.user_address["mintNumber"]! > 0: "mint for this address is not reserved"
            }
                
            let vaultRef = self.ownerVault!.borrow()
                ?? panic("Could not borrow reference to owner token vault")
            vaultRef.deposit(from: <-flowPayment)
            var template = TriQuetaNFT.getTemplateById(templateId: templateId)
            assert(template.issuedSupply + mintNumbers <= template.maxSupply, message: "template reached to its max supply")
            
            var i: UInt64 = 0
            while i < mintNumbers {
                TriQueta.adminRef.borrow()!.mintNFT(templateId: templateId, account: receiptAddress)
                i = i + 1
            }
            let mintsData = TriQueta.allReserved[dropId]![receiptAddress]!.user_address.remove(key: "mintNumber")
            let reserveData = TriQueta.allReserved[dropId]!.remove(key: receiptAddress)
            let mints = TriQueta.reservedMints[dropId]!
            TriQueta.reservedMints[dropId] = mints.saturatingSubtract(mintNumbers)

            emit DropPurchasedWithFlow(dropId: dropId, templateId: templateId, mintNumbers: mintNumbers, receiptAddress: receiptAddress,price: price)
        }

        pub fun ReserveUserNFT(dropId: UInt64, templateId: UInt64, receiptAddress: Address, mintNumbers: UInt64){
            pre {
                mintNumbers > 0: "mint number must be greater than zero"
                mintNumbers <= 10: "mint numbers must be less than ten"
                dropId != nil : "invalid drop id"
                receiptAddress !=nil: "invalid receipt Address"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                TriQueta.allDrops[dropId]!.startDate <= getCurrentBlock().timestamp: "drop not started yet"
                TriQueta.allDrops[dropId]!.endDate > getCurrentBlock().timestamp: "drop already ended"
            }

            let templateData = TriQuetaNFT.getTemplateById(templateId: templateId)
            let mintAvailble = templateData.maxSupply
            let issuedSupply = templateData.issuedSupply
            assert(issuedSupply + mintNumbers <= mintAvailble, message: "mints not available")
            let mintdata =  TriQueta.reservedMints[dropId]
            if  mintdata == nil {
                assert(issuedSupply + mintNumbers <= mintAvailble, message: "mints reached")
                TriQueta.reservedMints[dropId] = mintNumbers
            }
            else{
                let mints =  TriQueta.reservedMints[dropId]!
                assert(issuedSupply + mints <= mintAvailble, message: "mints reached")
                assert(issuedSupply + mints + mintNumbers  <= mintAvailble, message: "mints not available") 
                TriQueta.reservedMints[dropId] = mints.saturatingAdd(mintNumbers)
            }
            let userData: {String : UInt64} = {"mintNumber": mintNumbers}
            let data = TriQueta.RserveMints(user_address: userData)
            TriQueta.allReserved.insert(key: dropId, {receiptAddress: data})
            emit MintNumberReserved(dropId: dropId, receiptAddress: receiptAddress)
        }

        pub fun removeReservedUserNFT(dropId: UInt64, receiptAddress:Address, mintNumbers: UInt64): Bool{
            pre {
                dropId != nil : "invalid drop id"
                receiptAddress !=nil: "invalid receipt Address"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                TriQueta.allReserved[dropId] != nil: "drop id does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress] != nil: "given address does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress]!.user_address["mintNumber"]! > 0: "mint for this address is not reserved"
            }
            let mintsData = TriQueta.allReserved[dropId]![receiptAddress]!.user_address.remove(key: "mintNumber")
            let reserveData = TriQueta.allReserved[dropId]!.remove(key: receiptAddress)
            let mints = TriQueta.reservedMints[dropId]!
            TriQueta.reservedMints[dropId] = mints.saturatingSubtract(mintNumbers)
            return true
         }

        pub fun getUserMintsByDropId(dropId: UInt64, receiptAddress:Address): Bool{
            pre {
                dropId != nil : "invalid drop id"
                receiptAddress !=nil: "invalid receipt Address"
                TriQueta.allDrops[dropId] != nil: "drop id does not exist"
                TriQueta.allReserved[dropId] != nil: "drop id does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress] != nil: "given address does not exist in reserved"
                TriQueta.allReserved[dropId]![receiptAddress]!.user_address["mintNumber"]! > 0: "mint for this address is not reserved"
            }
            let reserveData = TriQueta.allReserved[dropId]!
            let userMintData = reserveData[receiptAddress]!.user_address["mintNumber"]
            return userMintData! > 0
        }

        init(){
            self.ownerVault = nil
        }
    }

    // getDropById returns the IDs that the specified Drop id
    // is associated with 
    pub fun getDropById(dropId: UInt64): Drop {
        return self.allDrops[dropId]!
    }

    // getAllDrops returns all the Drops in TriQueta
    // Returns: A dictionary of all the Drop that have been created
    pub fun getAllDrops(): {UInt64: Drop} {
        return self.allDrops
    }

    init() {
        // Initialize contract fields
        self.allDrops = {}
        self.allReserved = {}
        self.reservedMints = {}

        self.DropAdminStoragePath = /storage/TriQuetaDropAdmin
        // get the private capability to the admin resource interface
        // to call the functions of this interface.
        self.adminRef = self.account.getCapability<&{TriQuetaNFT.NFTMethodsCapability}>(TriQuetaNFT.NFTMethodsCapabilityPrivatePath)

        // Put the Drop Admin in storage
        self.account.save(<- create DropAdmin(), to: self.DropAdminStoragePath)
        emit ContractInitialized()
    }
}
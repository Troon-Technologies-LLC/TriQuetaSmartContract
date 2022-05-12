import TriQuetaNFT from 0x118cabc98306f7d1
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
    pub event DropUpdated(dropId: UInt64, startDate: UFix64, endDate: UFix64)
    // Contract level paths for storing resources
    pub let DropAdminStoragePath: StoragePath
    // The capability that is used for calling the admin functions 
    access(contract) let adminRef: Capability<&{TriQuetaNFT.NFTMethodsCapability}>
    // Variable size dictionary of Drop structs
    access(self) var allDrops: {UInt64: Drop}
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

        //Admin can update start-date, end-date and templates of a drop
        // start-date only updated if sale is not started yet
        // end-date can updated any-way, Admin need to check if templates are soldout than no need to active that drop 
        // templates can be updated, if sale is not started yet
        pub fun updateDrop(startDate: UFix64?, endDate: UFix64?, templates: {UInt64: AnyStruct}?){
            pre{
                (startDate==nil) || (startDate!=nil &&  self.startDate > getCurrentBlock().timestamp && startDate! >= getCurrentBlock().timestamp): "can't update start date"
                (endDate==nil) || (endDate!=nil && endDate! > getCurrentBlock().timestamp): "can't update end date"
                (templates==nil) || (templates != nil && templates!.keys.length != 0 && self.startDate > getCurrentBlock().timestamp) : "can't update templates"
                !(startDate==nil && endDate==nil && templates==nil):"All values are nil"
           }

            var isUpdated:Bool = true;
            var errorMessage:String = "";

            if(startDate != nil && startDate! < self.endDate){
                self.startDate = startDate!
            }else{
                isUpdated = false;
                errorMessage = "start-date should be greater than end-date"
            }

            if(endDate != nil && endDate! > self.startDate) {
                self.endDate = endDate!
            }else{
                isUpdated = false;
                errorMessage = "end-date should be greater than end-date"
            }

            if(templates != nil) {
                self.templates = templates!
            }

            assert(isUpdated, message: errorMessage);
            
            emit DropUpdated(dropId: self.dropId, startDate: self.startDate, endDate: self.endDate)
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

       pub fun updateDrop(dropId: UInt64, startDate: UFix64?, endDate: UFix64?, templates: {UInt64: AnyStruct}?) {
            pre{
                dropId != nil: "invalid drop id"
                TriQueta.allDrops[dropId] != nil: "drop id does not exists"
                startDate != 0.0 || endDate != 0.0: "please provide valid dates"
            }

            if(templates !=nil && templates!.keys.length != 0){
                var areValidTemplates: Bool = true
                for templateId in templates!.keys {
                    var template = TriQuetaNFT.getTemplateById(templateId: templateId)
                    if(template == nil){
                        areValidTemplates = false
                        break
                    }
                }
                assert(areValidTemplates, message:"templateId is not valid")
            }
            TriQueta.allDrops[dropId]!.updateDrop(startDate: startDate, endDate: endDate, templates: templates)
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
            }

            var template = TriQuetaNFT.getTemplateById(templateId: templateId)
            assert(template.issuedSupply + mintNumbers <= template.maxSupply, message: "template reached to its max supply") 
            var i: UInt64 = 0
            while i < mintNumbers {
                TriQueta.adminRef.borrow()!.mintNFT(templateId: templateId, account: receiptAddress)
                i = i + 1
            }

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

            emit DropPurchasedWithFlow(dropId: dropId, templateId: templateId, mintNumbers: mintNumbers, receiptAddress: receiptAddress,price: price)
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

        self.DropAdminStoragePath = /storage/TriQuetaDropAdmin
        // get the private capability to the admin resource interface
        // to call the functions of this interface.
        self.adminRef = self.account.getCapability<&{TriQuetaNFT.NFTMethodsCapability}>(TriQuetaNFT.NFTMethodsCapabilityPrivatePath)

        // Put the Drop Admin in storage
        self.account.save(<- create DropAdmin(), to: self.DropAdminStoragePath)
        emit ContractInitialized()
    }
}
import NonFungibleToken from 0x631e88ae7f1d7c20

pub contract TriQuetaNFT: NonFungibleToken {

    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event NFTDestroyed(id: UInt64)
    pub event NFTMinted(nftId: UInt64, templateId: UInt64, mintNumber: UInt64)
    pub event BrandCreated(brandId: UInt64, brandName: String, author: Address, data:{String: String})
    pub event BrandUpdated(brandId: UInt64, brandName: String, author: Address, data:{String: String})
    pub event SchemaCreated(schemaId: UInt64, schemaName: String, author: Address)
    pub event TemplateCreated(templateId: UInt64, brandId: UInt64, schemaId: UInt64, maxSupply: UInt64)
    pub event TemplateRemoved(templateId: UInt64)
    pub event TemplateUpdated(templateId: UInt64)
    pub event TemplateLocked(templateId: UInt64)

    // Paths
    pub let AdminResourceStoragePath: StoragePath
    pub let NFTMethodsCapabilityPrivatePath: PrivatePath
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let AdminStorageCapability: StoragePath
    pub let AdminCapabilityPrivate: PrivatePath

    // Latest brand-id
    pub var lastIssuedBrandId: UInt64

    // Latest schema-id
    pub var lastIssuedSchemaId: UInt64

    // Latest brand-id
    pub var lastIssuedTemplateId: UInt64

    // Total supply of all NFTs that are minted using this contract
    pub var totalSupply: UInt64
    
    // A dictionary that stores all Brands against it's brand-id.
    access(self) var allBrands: {UInt64: Brand}

    // A dictionary that stores all Schemas against it's schema-id.
    access(self) var allSchemas: {UInt64: Schema}

    // A dictionary that stores all Templates against it's template-id.
    access(self) var allTemplates: {UInt64: Template}

    // A dictionary that stores all NFTs against it's nft-id.
    access(self) var allNFTs: {UInt64: NFTData}

    // Accounts ability to add capability
    access(self) var whiteListedAccounts: [Address]

    /*
    * Schema Enum
    *   Schema will be data-structure of a NFT. 
    *   Schema will support following types e.g: String, Int, Fix64, Bool, Address, Array and Any
    */
    pub enum SchemaType: UInt8 {
        pub case String
        pub case Int
        pub case Fix64
        pub case Bool
        pub case Address
        pub case Array
        pub case Any
    }


    /*
    * Brand
    *   Brand will represent a company or author of NFTs. 
    *   A Brand has id, name, author and data for brand. 
    *   Brand data is basic dictionary, so it can contain any of brand data
    */
    pub struct Brand {
        pub let brandId: UInt64
        pub let brandName: String
        pub let author: Address
        access(contract) var data: {String: String}
        
        init(brandName: String, author: Address, data: {String: String}) {
            pre {
                brandName.length > 0: "Brand name is required";
            }

            let newBrandId = TriQuetaNFT.lastIssuedBrandId
            self.brandId = newBrandId
            self.brandName = brandName
            self.author = author
            self.data = data
        }
        pub fun update(data: {String: String}) {
            self.data = data
        }
    }

    /*
    * Schema
    *   Schema will be data-structure of a NFT. 
    *   Schema has key name and data-type of its value, which will be used for serialization and deserialization (in future work)
    */
    pub struct Schema {
        pub let schemaId: UInt64
        pub let schemaName: String
        pub let author: Address
        access(contract) let format: {String: SchemaType}

        init(schemaName: String, author: Address, format: {String: SchemaType}){
            pre {
                schemaName.length > 0: "Could not create schema: name is required"
            }

            let newSchemaId = TriQuetaNFT.lastIssuedSchemaId
            self.schemaId = newSchemaId
            self.schemaName = schemaName
            self.author = author
            self.format = format
        }
    }

    /*
    * Template
    *   Template will be blueprint of a NFT. 
    *   Template has relation between brand and schema. It also manage max-supply of a NFT and its issued-supply.
    *   Template also contain meta data of a NFT, which make it as a blueprint of NFT
    */
    pub struct Template {
        pub let templateId: UInt64
        pub let brandId: UInt64
        pub let schemaId: UInt64
        pub var maxSupply: UInt64
        pub var issuedSupply: UInt64
        pub var locked: Bool
        pub var immutableData: {String: AnyStruct}
        access(contract) var mutableData: {String: AnyStruct}?

        init(brandId: UInt64, schemaId: UInt64, maxSupply: UInt64, immutableData: {String: AnyStruct}, mutableData: {String: AnyStruct}?) {
            pre {
                TriQuetaNFT.allBrands[brandId] != nil:"Brand Id must be valid"
                TriQuetaNFT.allSchemas[schemaId] != nil:"Schema Id must be valid"
                maxSupply > 0 : "MaxSupply must be greater than zero"
                immutableData != nil: "ImmutableData must not be nil"
            }

            // Before creating template, we need to check template data, if it is valid against given schema or not
            let schema = TriQuetaNFT.allSchemas[schemaId]!
            TriQuetaNFT.validateDataAgainstSchema(format: schema.format, data: immutableData)
            self.templateId = TriQuetaNFT.lastIssuedTemplateId
            self.brandId = brandId
            self.schemaId = schemaId
            self.maxSupply = maxSupply
            self.immutableData = immutableData
            self.mutableData = mutableData
            self.issuedSupply = 0
            self.locked = false
        }

         // a method to update entire MutableData field of Template
        pub fun updateMutableData(mutableData: {String: AnyStruct}) {     
                self.mutableData = mutableData
        }

        // a method to update or add particular pair in MutableData field of Template
        pub fun updateMutableAttribute(key: String, value: AnyStruct){
            pre{
                self.mutableData != nil: "Mutable data is nil, update complete mutable data of template instead!"
            }
            self.mutableData?.insert(key: key, value)
        }
        // a method to get ImmutableData field of Template
        pub fun getImmutableData(): {String:AnyStruct} {
            return self.immutableData
        }
        
        // a method to get MutableData field of Template
        pub fun getMutableData(): {String: AnyStruct}? {
            return self.mutableData
        }
        
        // A method to increment issued supply for template
        access(contract) fun incrementIssuedSupply(): UInt64 {
            pre {
                self.issuedSupply < self.maxSupply: "Template reached max supply"
            }

            self.issuedSupply = self.issuedSupply + 1
            return self.issuedSupply
        }

        // A method to lock the template
        pub fun lockTemplate(status: Bool){
            pre {
                self.locked != true: "template is locked"
                status != false: "invalid status" 
            }
            self.locked = status
        }
    }

    /*
    * NFTData
    *   NFTData is a structure than manage the relation between a NFT and template.
    *   Also it manage mint-number of a NFT
    */
    pub struct NFTData {
        pub let templateID: UInt64
        pub let mintNumber: UInt64
        access(contract) var immutableData: {String: AnyStruct}?

        init(templateID: UInt64, mintNumber: UInt64, immutableData: {String: AnyStruct}?) {
            self.templateID = templateID
            self.mintNumber = mintNumber
            self.immutableData = immutableData
        }

        // a method to get the immutable data of the NFT
        pub fun getImmutableData(): {String: AnyStruct}? {
            return self.immutableData
        }
    }

    /*
    * NFT
    *   NFT is a resource that actually stays in user storage.
    *   NFT has id, data which include relation with template and minter number of that specific NFT
    */
    pub resource NFT: NonFungibleToken.INFT {
        pub let id: UInt64
        access(contract) let data: NFTData

        init(templateID: UInt64, mintNumber: UInt64, immutableData: {String: AnyStruct}?) {
            TriQuetaNFT.totalSupply = TriQuetaNFT.totalSupply + 1
            self.id = TriQuetaNFT.totalSupply
            TriQuetaNFT.allNFTs[self.id] = NFTData(templateID: templateID, mintNumber: mintNumber, immutableData: immutableData)
            self.data = TriQuetaNFT.allNFTs[self.id]!
            emit NFTMinted(nftId: self.id, templateId: templateID, mintNumber: mintNumber)
        }
        destroy(){
            emit NFTDestroyed(id: self.id)
        }
    }
    /** TriQuetaNFTCollectionPublic
    *   A public interface extending the standard NFT Collection with type information specific
    *   to NowWhere NFTs.
    */
    pub resource interface TriQuetaNFTContractCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowNFTTriQuetaContract(id: UInt64): &TriQuetaNFT.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Reward reference: The ID of the returned reference is incorrect"
            }
        }
    }

    /** Collection
    *   Collection is a resource that lie in user storage to manage owned NFT resource
    */
    pub resource Collection: TriQuetaNFTContractCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: template does not exist in the collection")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @TriQuetaNFT.NFT
            let id = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }
            destroy oldToken
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowNFTTriQuetaContract returns a borrowed reference to a TriQuetaNFT
        // so that the caller can read data and call methods from it.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowNFTTriQuetaContract(id: UInt64): &TriQuetaNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &TriQuetaNFT.NFT
            } else {
                return nil
            }
        }
        init() {
            self.ownedNFTs <- {}
        }
        
        destroy () {
            destroy self.ownedNFTs
        }
    }

    // Special Capability, that is needed by user to utilize our contract. Only verified user can get this capability so it will add a KYC layer in our white-lable-solution
    pub resource interface UserSpecialCapability {
        pub fun addCapability(cap: Capability<&{NFTMethodsCapability}>)
    }

    // Interface, which contains all the methods that are called by any user to mint NFT and manage brand, schema and template funtionality
    pub resource interface NFTMethodsCapability {
        pub fun createNewBrand(brandName: String, data: {String: String})
        pub fun updateBrandData(brandId: UInt64, data: {String: String})
        pub fun createSchema(schemaName: String, format: {String: SchemaType})
        pub fun createTemplate(brandId: UInt64, schemaId: UInt64, maxSupply: UInt64, immutableData: {String: AnyStruct}, mutableData: {String: AnyStruct}?)
        pub fun updateTemplateMutableData(templateId: UInt64, mutableData: {String: AnyStruct})
        pub fun updateTemplateMutableAttribute(templateId: UInt64, key: String, value: AnyStruct)
        pub fun mintNFT(templateId: UInt64, account: Address, immutableData:{String:AnyStruct}?)
        pub fun removeTemplateById(templateId: UInt64)
        pub fun lockTemplateById(templateId: UInt64, status: Bool)

    }
    
    // AdminCapability to add whiteListedAccounts
    pub resource AdminCapability {
        
        pub fun addwhiteListedAccount(_user: Address) {
            pre{
                TriQuetaNFT.whiteListedAccounts.contains(_user) == false: "user already exist"
            }
            TriQuetaNFT.whiteListedAccounts.append(_user)
        }

        pub fun isWhiteListedAccount(_user: Address): Bool {
            return TriQuetaNFT.whiteListedAccounts.contains(_user)
        }

        init(){}
    }

    /* AdminResource
    *   AdminReource is a resource which is managing all the methods that a user (admin and end-user) can call e.g:    
    *   createBrand, createSchema, createTemplate, mintNFT, addCapbility etc
    */
    pub resource AdminResource: UserSpecialCapability, NFTMethodsCapability {
        // a variable which stores all Brands owned by a user
        priv var ownedBrands: {UInt64: Brand}
        // a variable which stores all Schema owned by a user
        priv var ownedSchemas: {UInt64: Schema}
        // a variable which stores all Templates owned by a user
        priv var ownedTemplates: {UInt64: Template}
        // a variable that store user capability to utilize methods 
        access(contract) var capability: Capability<&{NFTMethodsCapability}>?
        // method which provide capability to user to utilize methods
        pub fun addCapability(cap: Capability<&{NFTMethodsCapability}>) {
            pre {
                // we make sure the SpecialCapability is
                // valid before executing the method
                cap.borrow() != nil: "could not borrow a reference to the SpecialCapability"
                self.capability == nil: "resource already has the SpecialCapability"
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
            }
            // add the SpecialCapability
            self.capability = cap
        }

        // method to create new Brand, only access by the verified user
        pub fun createNewBrand(brandName: String, data: {String: String}) {
            pre {
                // the transaction will instantly revert if
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
            }

            let newBrand = Brand(brandName: brandName, author: self.owner?.address!, data: data)
            TriQuetaNFT.allBrands[TriQuetaNFT.lastIssuedBrandId] = newBrand
            emit BrandCreated(brandId: TriQuetaNFT.lastIssuedBrandId ,brandName: brandName, author: self.owner?.address!, data: data)
            self.ownedBrands[TriQuetaNFT.lastIssuedBrandId] = newBrand 
            TriQuetaNFT.lastIssuedBrandId = TriQuetaNFT.lastIssuedBrandId + 1
        }

        // method to update the existing Brand, only author of brand can update this brand
        pub fun updateBrandData(brandId: UInt64, data: {String: String}) {
            pre{
                // the transaction will instantly revert if
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                TriQuetaNFT.allBrands[brandId] != nil: "brand Id does not exists"
            }

            let oldBrand = TriQuetaNFT.allBrands[brandId]
            if self.owner?.address! != oldBrand!.author {
                panic("No permission to update others brand")
            }

            TriQuetaNFT.allBrands[brandId]!.update(data: data)
            emit BrandUpdated(brandId: brandId, brandName: oldBrand!.brandName, author: oldBrand!.author, data: data)
        }

        // method to create new Schema, only access by the verified user
        pub fun createSchema(schemaName: String, format: {String: SchemaType}) {
            pre {
                // the transaction will instantly revert if
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
            }

            let newSchema = Schema(schemaName: schemaName, author: self.owner?.address!, format: format)
            TriQuetaNFT.allSchemas[TriQuetaNFT.lastIssuedSchemaId] = newSchema
            emit SchemaCreated(schemaId: TriQuetaNFT.lastIssuedSchemaId, schemaName: schemaName, author: self.owner?.address!)
            self.ownedSchemas[TriQuetaNFT.lastIssuedSchemaId] = newSchema
            TriQuetaNFT.lastIssuedSchemaId = TriQuetaNFT.lastIssuedSchemaId + 1
            
        }

        // method to create new Template, only access by the verified user
        pub fun createTemplate(brandId: UInt64, schemaId: UInt64, maxSupply: UInt64, immutableData: {String: AnyStruct}, mutableData: {String: AnyStruct}?) {
            pre { 
                // the transaction will instantly revert if
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                self.ownedBrands[brandId] != nil: "Collection Id Must be valid"
                self.ownedSchemas[schemaId] != nil: "Schema Id Must be valid"
            }

            let newTemplate = Template(brandId: brandId, schemaId: schemaId, maxSupply: maxSupply, immutableData: immutableData, mutableData: mutableData)
            TriQuetaNFT.allTemplates[TriQuetaNFT.lastIssuedTemplateId] = newTemplate
            emit TemplateCreated(templateId: TriQuetaNFT.lastIssuedTemplateId, brandId: brandId, schemaId: schemaId, maxSupply: maxSupply)
            self.ownedTemplates[TriQuetaNFT.lastIssuedTemplateId] = newTemplate
            TriQuetaNFT.lastIssuedTemplateId = TriQuetaNFT.lastIssuedTemplateId + 1
        }

        //method to update the existing template's mutable data, only author of brand can update this template
        pub fun updateTemplateMutableData(templateId: UInt64, mutableData: {String: AnyStruct}) {
            pre{
                // the transaction will instantly revert if
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                TriQuetaNFT.allTemplates[templateId] != nil: "brand Id does not exists"
                
            }

            let oldTemplate = TriQuetaNFT.allTemplates[templateId]
            if self.owner?.address! != TriQuetaNFT.allBrands[oldTemplate!.brandId]!.author {
                panic("No permission to update others Template's Mutable Data")
            }

            TriQuetaNFT.allTemplates[templateId]!.updateMutableData(mutableData: mutableData)
            emit TemplateUpdated(templateId: templateId)
        }

        //method to update or add particular key-value pair in Template's mutable data, only author of brand can update this template
        pub fun updateTemplateMutableAttribute(templateId: UInt64, key: String, value:AnyStruct) {
            pre{
                // the transaction will instantly revert if the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                TriQuetaNFT.allTemplates[templateId] != nil: "Template Id does not exists"
                
            }

            let oldTemplate = TriQuetaNFT.allTemplates[templateId]
            if self.owner?.address! != TriQuetaNFT.allBrands[oldTemplate!.brandId]!.author {
                panic("No permission to update others Template's Mutable Data")
            }

            TriQuetaNFT.allTemplates[templateId]!.updateMutableAttribute(key: key, value: value)
            emit TemplateUpdated(templateId: templateId)
        }

        // method to mint NFT, only access by the verified user
        pub fun mintNFT(templateId: UInt64, account: Address, immutableData:{String:AnyStruct}?) {
            pre{
                // the transaction will instantly revert if 
                // the capability has not been added
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                self.ownedTemplates[templateId]!= nil: "Minter does not have specific template Id"
                TriQuetaNFT.allTemplates[templateId] != nil: "Template Id must be valid"
                TriQuetaNFT.allTemplates[templateId]!.locked != true: "You are not authorized because the template is locked" 
                }
            let receiptAccount = getAccount(account)
            let recipientCollection = receiptAccount
                .getCapability(TriQuetaNFT.CollectionPublicPath)
                .borrow<&{TriQuetaNFT.TriQuetaNFTContractCollectionPublic}>()
                ?? panic("Could not get receiver reference to the NFT Collection")
            var newNFT: @NFT <- create NFT(templateID: templateId, mintNumber: TriQuetaNFT.allTemplates[templateId]!.incrementIssuedSupply(), immutableData: immutableData)
            recipientCollection.deposit(token: <-newNFT)
        }

        // method to remove template by id
        pub fun removeTemplateById(templateId: UInt64) {
            pre {
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                templateId != nil: "invalid template id"
                TriQuetaNFT.allTemplates[templateId]!=nil: "template id does not exist"
                TriQuetaNFT.allTemplates[templateId]!.issuedSupply == 0: "could not remove template with given id"
                TriQuetaNFT.allTemplates[templateId]!.locked != true: "You are not authorized to remove the template because the template is locked" 
            }
            TriQuetaNFT.allTemplates.remove(key: templateId)
            emit TemplateRemoved(templateId: templateId)
        }

        // method to lock template by id
        pub fun lockTemplateById(templateId: UInt64, status: Bool) {
            pre {
                self.capability != nil: "I don't have the special capability :("
                TriQuetaNFT.whiteListedAccounts.contains(self.owner!.address): "you are not authorized for this action"
                templateId != nil: "invalid template id"
                TriQuetaNFT.allTemplates[templateId]!= nil: "template id does not exist"
                TriQuetaNFT.allTemplates[templateId]!.locked != true: "Template is already locked"
                status != false: "invalid status" 
            }
            TriQuetaNFT.allTemplates[templateId]!.lockTemplate(status: status)
            emit TemplateLocked(templateId: templateId)
        }

        init() {
            self.ownedBrands = {}
            self.ownedSchemas = {}
            self.ownedTemplates = {}
            self.capability = nil
        }
    }
    
    // method to create empty Collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create TriQuetaNFT.Collection()
    }

    // method to create Admin Resources
    pub fun createAdminResource(): @AdminResource {
        return <- create AdminResource()
    }
    
    /*  
    *   Method to validate template's Immutable data as per the one defined in related schema format
    *   Immutable data's keys and their value types must be according to the schema format defination
    */
    pub fun validateDataAgainstSchema(format: {String: SchemaType}, data: {String: AnyStruct}) {

        var invalidKey: String = ""
        var isValidTemplate = true

        for key in data.keys {
            let value = data[key]!
            if(format[key] == nil) {
                isValidTemplate = false
                invalidKey = "key $".concat(key.concat(" not found"))
                break
            }
            if format[key] == TriQuetaNFT.SchemaType.String {
                if(value as? String == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }
            else if format[key] == TriQuetaNFT.SchemaType.Int {
                if(value as? Int == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            } 
            else if format[key] == TriQuetaNFT.SchemaType.Fix64 {
                if(value as? Fix64 == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }else if format[key] == TriQuetaNFT.SchemaType.Bool {
                if(value as? Bool == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }else if format[key] == TriQuetaNFT.SchemaType.Address {
                if(value as? Address == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }
            else if format[key] == TriQuetaNFT.SchemaType.Array {
                if(value as? [AnyStruct] == nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }
            else if format[key] == TriQuetaNFT.SchemaType.Any {
                if(value as? {String:AnyStruct} ==nil) {
                    isValidTemplate = false
                    invalidKey = "key $".concat(key.concat(" has type mismatch"))
                    break
                }
            }
        }
            assert(isValidTemplate, message: "invalid template data. Error: ".concat(invalidKey))
    }
    
    // method to get all brands
    pub fun getAllBrands(): {UInt64: Brand} {
        return TriQuetaNFT.allBrands
    }

    // method to get brand by id
    pub fun getBrandById(brandId: UInt64): Brand {
        pre {
            TriQuetaNFT.allBrands[brandId] != nil: "brand Id does not exists"
        }
        return TriQuetaNFT.allBrands[brandId]!
    }

    // method to get all schema
    pub fun getAllSchemas(): {UInt64: Schema} {
        return TriQuetaNFT.allSchemas
    }

    // method to get schema by id
    pub fun getSchemaById(schemaId: UInt64): Schema {
        pre {
            TriQuetaNFT.allSchemas[schemaId] != nil: "schema id does not exist"
        }
        return TriQuetaNFT.allSchemas[schemaId]!
    }

    // method to get all templates
    pub fun getAllTemplates(): {UInt64: Template} {
        return TriQuetaNFT.allTemplates
    }

    // method to get template by id
    pub fun getTemplateById(templateId: UInt64): Template {
        pre {
            TriQuetaNFT.allTemplates[templateId]!=nil: "Template id does not exist"
        }
        return TriQuetaNFT.allTemplates[templateId]!
    } 
    
    // method to get template is locked by id
    pub fun isTemplateLocked(templateId: UInt64): Bool {
        pre {
            TriQuetaNFT.allTemplates[templateId]!= nil: "Template id does not exist"
        }
        return TriQuetaNFT.allTemplates[templateId]!.locked
    }

    //method to get data at immutableData field of Template
    pub fun getImmutableData(templateId: UInt64): {String:AnyStruct} {
        pre {
            TriQuetaNFT.allTemplates[templateId]!= nil: "Template id does not exist"
        }
        return TriQuetaNFT.allTemplates[templateId]!.getImmutableData()
    }

    //method to get data at mutableData field of Template
    pub fun getMutableData(templateId: UInt64): {String: AnyStruct}? {
        pre {
            TriQuetaNFT.allTemplates[templateId]!= nil: "Template id does not exist"
        }
        return TriQuetaNFT.allTemplates[templateId]!.getMutableData()
    }


    // method to get nft-data by id
    pub fun getNFTDataById(nftId: UInt64): NFTData {
        pre {
            TriQuetaNFT.allNFTs[nftId]!=nil:"nft id does not exist"
        }
        return TriQuetaNFT.allNFTs[nftId]!
    }

    // Initialize all variables with default values
    init(){
        self.lastIssuedBrandId = 1
        self.lastIssuedSchemaId = 1
        self.lastIssuedTemplateId = 1
        self.totalSupply = 0
        self.allBrands = {}
        self.allSchemas = {}
        self.allTemplates = {}
        self.allNFTs = {}
        self.whiteListedAccounts = [self.account.address]

        self.AdminResourceStoragePath = /storage/TriQuetaAdminResource
        self.CollectionStoragePath = /storage/TriQuetaCollection
        self.CollectionPublicPath = /public/TriQuetaCollection
        self.AdminStorageCapability = /storage/TriQuetaAdminCapability
        self.AdminCapabilityPrivate = /private/TriQuetaAdminCapability
        self.NFTMethodsCapabilityPrivatePath = /private/TriQuetaNFTMethodsCapability
        
        self.account.save<@AdminCapability>(<- create AdminCapability(), to: /storage/AdminStorageCapability)
        self.account.link<&AdminCapability>(self.AdminCapabilityPrivate, target: /storage/AdminStorageCapability)
        self.account.save<@AdminResource>(<- create AdminResource(), to: self.AdminResourceStoragePath)
        self.account.link<&{NFTMethodsCapability}>(self.NFTMethodsCapabilityPrivatePath, target: self.AdminResourceStoragePath)

        emit ContractInitialized()
    }
}
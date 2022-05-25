## Technical Summary and Code Documentation

## Instructions for creating Brand, Schema, Template and Mint Templates

A common order of creating NFT would be

1. Creating new Brand with `transactions/createBrand.cdc` transaction.
2. Creating new Schema with `transactions/createSchema.cdc` transaction.
3. Creating new Template with `transactions/createTemplate.cdc` transaction.
4. Create NFT receiver with `transaction/setupAccount.cdc` transaction for the end-user who will receive the NFT.
5. Mint NFT and transfer that NFT to given address(having NFT-receiver) with `transactions/mintTemplate.cdc` transaction.

You can also call scripts to fetch and verify the data, basic scripts would be

1. Get all brands ids by calling `scripts/getAllBrands.cdc` script.
2. Get specific brand data by its brand-id by calling `scripts/getBrandById.cdc` script.
3. Get all schemas by calling `scripts/getallSchema.cdc` script.
4. Get specific schema by its schema-id by calling `scripts/getSchemaById.cdc` script.
5. Get all templates by calling `scripts/getAllTemplates.cdc` script.
6. Get specific template by its tamplate-id by calling `scripts/getTemplateById.cdc` script.
7. Get all nfts of an address by calling `scripts/getNFTTemplateData.cdc` script.
8. Get specific nft-data by its nft-id by calling `scripts/getNFTDataById.cdc` script.

### TriQuetaNFT Events

- Contract Initialized ->
  `pub event ContractInitialized()`
  This event is emitted when the `TriQuetaNFT` will be initialized.

- Event for Withdraw NFT ->
  `pub event Withdraw(id: UInt64, from: Address?)`
  This event is emitted when NFT will be withdrawn.

- Event for Deposit NFT ->
  `pub event Deposit(id: UInt64, to: Address?)`
  This event is emitted when NFT will be deposited.

- Event for Brand ->
  `pub event BrandCreated(brandId: UInt64, brandName: String, author: Address, data: {String:String})`
  Emitted when a new Brand will be created and added to the smart Contract.

- Event for Brand Updation ->
  `pub event BrandUpdated(brandId: UInt64, brandName: String, author: Address, data: {String:String})`
  Emitted when a Brand will be update

- Event for Schema ->
  `pub event SchemaCreated(schemaId: UInt64, schemaName: String, author: Address)`
  Emitted when a new Schema will be created

- Event for Template ->
  `pub event TemplateCreated(templateId: UInt64, brandId: UInt64, schemaId: UInt64, maxSupply: UInt64)`
  Emitted when a new Template will be created

- Event for Template Mint ->
  `pub event NFTMinted(nftId: UInt64, templateId: UInt64, mintNumber: UInt64)`
  Emitted when a Template will be Minted and save as NFT

- Event for Template removed ->
  ` pub event TemplateRemoved(templateId: UInt64)`
  Emitted when a Template will be removed

## TriQuetaNFT Addresses

`TriQuetaNFT.cdc`: This is the main TriQuetaNFT smart contract that defines
the core functionality of the NFT.

| Network | Contract Address     |
| ------- | -------------------- |
| Testnet | `0x118cabc98306f7d1` |

## TriQuetaNFT Overview Technical

TriQuetaNFT represent a standard to create an NFT. We inherited NonFungibleToken contract interface to conform our nft standard with the existent NFT standard by Flow Blockchain.
To Create an NFT, you first have to create a Brand structure which contains following fields:

- brandId: UInt64 (Id of Brand)
- brandName: String (Name of Brand)
- data: {String: String} (Metadata of Brand)
  The transaction will create the brand taking input above mentioned fields. We can update metadata later using Update function(only owner can perform this action).

We also have to Create Schema Structure before creating a template using the following fields:

- schameName: String (Name of Schema)
- format: {String: SchemaType}
  The transaction will create the schema taking input above mentioned fields. This schema is like a database structure which is already given and if you want to create a template using that schema. You have to follow schema Structure.

We will then create Template using brandId and schemaId that we created before. Without brandId and schemaId we can't create template. We can create Template using following fields:

- brandId: UInt64 (Foreign Id of Brand)
- schemaId: UInt64 (Foreign Id of Schema)
- maxSupply: UInt64 (maximum NFTs that could be created using that template)
- immutableData: {String: AnyStruct} (Immutable metadata of template)

We then have our Resource type NFT(actual asset) that represents a template owns by a user. It stores its unique Id and NFTData structure contains TemplateId and mintNumber of Template.

The above transaction can only be performed by an Admin having an Admin resource that will give special capability to any user to create Brands, Schema and Template.

### Deployment Contract on Emulator

- Run `flow project deploy --network emulator`
  - All contracts are deployed to the emulator.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.

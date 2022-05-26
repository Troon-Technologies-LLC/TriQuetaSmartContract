## How to Deploy and Test the TriQueta Contract in VSCode

The initial step to use any smart-contract is to deploy that contract to any network e.g: mainnet, testnet or emulator.
In our case we will deploy our contract to emulator.
First you need to install vs-code extension to your VS Code, you can see [vscode extension instructions](https://docs.onflow.org/vscode-extension/) for further instructions

Once extension is installed now you nee to follow bellow steps:

1.  Start the emulator with the `Run emulator` vscode command.
2.  Open the `NonFungibleToken.cdc` file from the [flow-nft repo](https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc) and the `TriQuetaNFT.cdc` file.
3.  In `NonFungibleToken.cdc`, click the `deploy contract to account`
    above the `Dummy` contract at the bottom of the file to deploy it.
    This also deploys the `NonFungibleToken` interface.
4.  In `TriQuetaNFT.cdc`, make sure it imports `NonFungibleToken` from
    the account you deployed it to.
5.  Click the `deploy contract to account` button that appears over the
    `TriQuetaNFT` contract declaration to deploy it to a new account.

The above steps deploy the contract code and it will initlialize the
contract storage variables.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.
If you are running these transactions manually in the Flow Playground or
vscode extension, you will need to remove the transaction arguments and
hard code the values that they are used for.

## TriQuetaNFT Addresses

`TriQuetaNFT.cdc`: This is the main TriQuetaNFT smart contract that defines
the core functionality of the NFT.

| Network | Contract Address     |
| ------- | -------------------- |
| Testnet | `0x8f5c3c561b83eae3` |

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

## TriQuetaNFT Events

- ` pub event ContractInitialized()`
  This event is emitted when the `TriQuetaNFT` will be initialized.

## Event for Brand

- `pub event BrandCreated(brandId:UInt64, brandName:String, author:Address, data:{String:String})`
  Emitted when a new Brand will be created and added to the smart Contract.

- `pub event BrandUpdated(brandId: UInt64, brandName: String, author: Address, data:{String: String})`
  Emitted when a Brand is updated on Smart-contract.

## Event for Schema

- `pub event SchemaCreated(schemaId:UInt64, schemaName:String, author:Address)`
  Emitted when a new Schema will be created

## Event for Template

- `pub event TemplateCreated(templateId:UInt64, brandId:UInt64, schemaId:UInt64, maxSupply:UInt64)`
  Emitted when a new Template will be created

- `pub event TemplateRemoved(templateId: UInt64)`
  Emitted when a Template is updated

## Event for NFT

- `pub event NFTMinted(nftId:UInt64, templateId:UInt64, mintNumber: UInt64`
  Emitted when a NFT is minted

- `pub event NFTDestroyed(id: UInt64)`
  Emitted when a NFT is destroyed

- `pub event Deposit(id: UInt64, to: Address?)`
  Emitted when a NFT is deposited to any address

- `pub event Withdraw(id: UInt64, from: Address?)`
  Emitted when a NFT is withdrawn

## Start Flow

### Creating the contract and minting a token

`flow project start-emulator`

`flow project deploy`

`flow keys generate`

## Create Brand

`flow transactions send transactions/createBrand.cdc --arg String:"test" --args-json "[{\"type\":\"String\",\"value\":\"test\"},{\"type\":\"String\",\"value\":\"abc\"}]" --network testnet --signer testnet-account`

## Create Schema

`flow transactions send transactions/createSchema.cdc --arg String:"test" --network testnet --signer testnet-account`

## Create Template

`flow transactions send transactions/createTemplate.cdc --arg UInt64:"1" UInt64:"1" UInt64:"100" --args-json "[{\"type\":\"String\",\"value\":\"test\"},{\"type\":\"String\",\"value\":\"abc\"}]" --network testnet --signer testnet-account`

## Mint NFT

`flow transactions send transactions/mintNFT.cdc --arg UInt64:"1" Address:"0x01" --network testnet --signer testnet-account`

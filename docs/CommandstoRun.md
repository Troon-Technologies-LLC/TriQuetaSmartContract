## How to Deploy and Test the Top Shot Contract in VSCode

The first step for using any smart contract is deploying it to the blockchain,
or emulator in our case. Do these commands in vscode.
See the [vscode extension instructions](https://docs.onflow.org/docs/visual-studio-code-extension)
to learn how to use it.

1.  Start the emulator with the `Run emulator` vscode command.
2.  Open the `NonFungibleToken.cdc` file from the [flow-nft repo](https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc) and the `NFTContract.cdc` file.
3.  In `NonFungibleToken.cdc`, click the `deploy contract to account`
    above the `Dummy` contract at the bottom of the file to deploy it.
    This also deploys the `NonFungibleToken` interface.
4.  In `NFTContract.cdc`, make sure it imports `NonFungibleToken` from
    the account you deployed it to.
5.  Click the `deploy contract to account` button that appears over the
    `NFTContract` contract declaration to deploy it to a new account.

The above steps deploy the contract code and it will initlialize the
contract storage variables.

After the contracts have been deployed, you can run the sample transactions
to interact with the contracts. The sample transactions are meant to be used
in an automated context, so they use transaction arguments and string template
fields. These make it easier for a program to use and interact with them.
If you are running these transactions manually in the Flow Playground or
vscode extension, you will need to remove the transaction arguments and
hard code the values that they are used for.

## NFTContract Addresses

`NFTContract.cdc`: This is the main NFTContract smart contract that defines
the core functionality of the NFT.

| Network | Contract Address     |
| ------- | -------------------- |
| Testnet | `0x8f5c3c561b83eae3` |

## Instructions for creating Brand, Schema, Template and Mint Templates

A common order of creating NFT would be

1. Creating new Brand with `transactions/createBrand.cdc`.
2. Creating new Schema with `transactions/createSchema.cdc`.
3. Creating new Template with `transactions/createTemplate.cdc`.
4. Create NFT receiver with `transaction/setupAccount.cdc`.
5. Create Mint of Templates and transfer to Address(having Setup Account) with `transactions/mintTemplate.cdc`

You can also see the scripts in `transactions/scripts.cdc` to see how information
can be read from the NFTContract.

## NFTContract Events

- ` pub event ContractInitialized()`

  This event is emitted when the `NFTContract` will be initialized.

## Event for Brand

Emitted when a new Brand will be created and added to the smart Contract.

- `pub event BrandCreated(brandId:UInt64, brandName:String, author:Address, data:{String:String})`
  Emitted when a Brand will be update

## Event for Schema

- `pub event SchemaCreated(schemaId:UInt64, schemaName:String, author:Address)`
  Emitted when a new Schema will be created

## Event for Template

- `pub event TemplateCreated(templateId:UInt64, brandId:UInt64, schemaId:UInt64, maxSupply:UInt64)`
  Emitted when a new Template will be created

## Event for Template Mint

- `pub event NFTMinted(nftId:UInt64, templateId:UInt64, mintNumber: UInt64`
  Emitted when a Template will be Minted and save as NFT

## Start Flow

### Creating the contract and minting a token

flow project start-emulator

flow project deploy

flow keys generate

## Create Template argument is max supply

flow transactions send transactions/createBrand.cdc --arg String:"test" --args-json "[{\"type\":\"String\",\"value\":\"test\"},{\"type\":\"String\",\"value\":\"abc\"}]" --network testnet --signer testnet-account

## Mint NFT argument template ID

flow transactions send transactions/mint.cdc --arg UInt64:2 --network testnet --signer testnet-account

## Command to lock template argument template ID

flow transactions send transactions/locktemplate.cdc --arg UInt64:1 --network testnet --signer testnet-account

## Command to unlock template argument template ID

flow transactions send transactions/unlocktemplate.cdc --arg UInt64:1 --network testnet --signer testnet-account

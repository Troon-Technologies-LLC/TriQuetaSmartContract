package test

import (
	"regexp"
	"testing"

	"github.com/onflow/cadence"
	emulator "github.com/onflow/flow-emulator"
	"github.com/onflow/flow-go-sdk"
	sdk "github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/templates"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	ft_contracts "github.com/onflow/flow-ft/lib/go/contracts"
	nft_contracts "github.com/onflow/flow-nft/lib/go/contracts"
)

const (
	TriQuetaRootPath                      = "../.."
	NFTContractPath                       = TriQuetaRootPath + "/contracts/NFTContract.cdc"
	TriQuetaPath                  		  = TriQuetaRootPath + "/contracts/TriQueta.cdc"
	NFTContractTransferTokensPath         = TriQuetaRootPath + "/transactions/transferNFT.cdc"
	NFTContractDestroyTokensPath          = TriQuetaRootPath + "/transactions/destroyNFT.cdc"
	NFTContractMintTokensPath             = TriQuetaRootPath + "/transactions/mintNFT.cdc"
	NFTContractGetSupplyPath              = TriQuetaRootPath + "/scripts/getTotalSupply.cdc"
	NFTContractGetCollectionPath          = TriQuetaRootPath + "/scripts/getBrand.cdc"
	NFTContractGetCollectionCountPath     = TriQuetaRootPath + "/scripts/getBrandCount.cdc"
	NFTContractGetBrandNamePath           = TriQuetaRootPath + "/scripts/getBrandName.cdc"
	NFTContractGetBrandIDPath             = TriQuetaRootPath + "/scripts/getBrandIDs.cdc"
	NFTContractGetSchemaCountPath         = TriQuetaRootPath + "/scripts/getSchemaCount.cdc"
	NFTContractGetTemplateCountPath       = TriQuetaRootPath + "/scripts/getTemplateCount.cdc"
	NFTContractGetNFTAddressPath          = TriQuetaRootPath + "/scripts/getNFTAddress.cdc"
	NFTContractGetNFTAddressCountPath     = TriQuetaRootPath + "/scripts/getAddressOwnedNFTCount.cdc"
	NFTContractCreateCollectionPath       = TriQuetaRootPath + "/transactions/createBrand.cdc"
	NFTContractUpdateBrandPath            = TriQuetaRootPath + "/transactions/UpdateBrand.cdc"
	NFTContractCreateSchemaPath           = TriQuetaRootPath + "/transactions/createSchema.cdc"
	NFTContractCreateTemplatePath         = TriQuetaRootPath + "/transactions/createTemplate.cdc"
	NFTContractSetupAccountPath           = TriQuetaRootPath + "/transactions/setupAccount.cdc"
	NFTContractSetupAdminAccountPath      = TriQuetaRootPath + "/transactions/setupAdminAccount.cdc"
	NFTContractAddAdminCapabilityPath     = TriQuetaRootPath + "/transactions/addAdminAccount.cdc"
	NFTContractSelfAddAdminCapabilityPath = TriQuetaRootPath + "/transactions/addNFTContractAdminAccount.cdc"
	NFTContractCreateDropPath             = TriQuetaRootPath + "/transactions/createDrop.cdc"
	TriQuetaPurchaseDropPath              = TriQuetaRootPath + "/transactions/purchaseDrop.cdc"
	TriQuetaRemoveDropPath                = TriQuetaRootPath + "/transactions/RemoveDrop.cdc"
	CapabilityAdminCheck                  = TriQuetaRootPath + "/transactions/CheckAdminCapability.cdc"
	TriQuetagetDropCountPath              = TriQuetaRootPath + "/scripts/getDropCount.cdc"
	TriQuetagetDropIdsPath                = TriQuetaRootPath + "/scripts/getDropIds.cdc"
	getDate                               = TriQuetaRootPath + "/scripts/getDate.cdc"
)

func NFTContractDeployContracts(emulator *emulator.Blockchain, testing *testing.T) (flow.Address, flow.Address, crypto.Signer, sdk.Address) {
	accountKeys := test.AccountKeyGenerator()
	adminAccountKey, adminSigner := accountKeys.NewWithSigner()

	nftCode := loadNonFungibleToken()
	nftAddr, err := emulator.CreateAccount(
		[]*flow.AccountKey{adminAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	require.NoError(testing, err)

	_, err = emulator.CommitBlock()
	assert.NoError(testing, err)

	address, err := emulator.CreateAccount([]*sdk.AccountKey{adminAccountKey}, nil)

	NFTContractCode := loadNFTContract(nftAddr.String())

	adminAddr, err := emulator.CreateAccount(
		[]*flow.AccountKey{adminAccountKey},
		[]templates.Contract{templates.Contract{
			Name:   "NFTContract",
			Source: string(NFTContractCode),
		}},
	)
	assert.NoError(testing, err)

	_, err = emulator.CommitBlock()
	assert.NoError(testing, err)

	return nftAddr, adminAddr, adminSigner, address
}

func TriQuetaReplaceAddressPlaceholders(code string, nonfungibleAddress, nftContractAddress string) []byte {
	return []byte(replaceImports(
		code,
		map[string]*regexp.Regexp{
			nonfungibleAddress: nftAddressPlaceholder,
			nftContractAddress: NFTContractAddressPlaceHolder,
		},
	))
}

func TriQuetaReplaceAddressPlaceholders(code string, nonfungibleAddress, nftContractAddress, TriQuetaAddress string) []byte {
	return []byte(replaceImports(
		code,
		map[string]*regexp.Regexp{
			nonfungibleAddress: nftAddressPlaceholder,
			nftContractAddress: NFTContractAddressPlaceHolder,
			TriQuetaAddress:    TriQuetaPlaceholder,
		},
	))
}

func loadFungibleToken() []byte {
	return ft_contracts.FungibleToken()
}

func loadNFTContract(nftAddr string) []byte {
	return []byte(replaceImports(
		string(readFile(NFTContractPath)),
		map[string]*regexp.Regexp{
			nftAddr: nftAddressPlaceholder,
		},
	))
}
func loadTriQueta(nftAddr string, nftContractAddr string) []byte {
	return []byte(replaceImports(
		string(readFile(TriQuetaPath)),
		map[string]*regexp.Regexp{
			nftAddr:         nftAddressPlaceholder,
			nftContractAddr: NFTContractAddressPlaceHolder,
		},
	))
}

func loadNFT(fungibleAddr flow.Address) []byte {
	return []byte(replaceImports(
		string(readFile(NFTContractPath)),
		map[string]*regexp.Regexp{
			fungibleAddr.String(): ftAddressPlaceholder,
		},
	))
}

func TriQuetaGenerateGetSupplyScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetSupplyPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaGenerateGetCollectionScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetCollectionPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractGenerateGetBrandCountScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetCollectionCountPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractGenerateGetBrandNameScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetBrandNamePath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractGenerateGetBrandIDsScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetBrandIDPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func GetSchema_CountScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetSchemaCountPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

// Template Script
func TriQuetaGenerateGetTemplateCountScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetTemplateCountPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

// Drops Script
func TriQuetaGenerateGetDropCountScript(fungibleAddr, NFTContract, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(TriQuetagetDropCountPath)),
		fungibleAddr.String(),
		NFTContract.String(),
		TriQuetaAddr.String(),
	)
}

// Drops Script
func TriQuetaGenerateGetDropIdsScript(fungibleAddr, NFTContract, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(TriQuetagetDropIdsPath)),
		fungibleAddr.String(),
		NFTContract.String(),
		TriQuetaAddr.String(),
	)
}

func getCurrentTime(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(getDate)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaGenerateGetNFTAddressScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetNFTAddressPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaGenerateGetNFTAddressCountScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractGetNFTAddressCountPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func loadNonFungibleToken() []byte {
	return nft_contracts.NonFungibleToken()
}

func TriQuetaCreateGenerateCollectionScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractCreateCollectionPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func CapabilityAccessScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(CapabilityAdminCheck)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaUpdateBrandScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractUpdateBrandPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaCreateGenerateSchemaScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractCreateSchemaPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaCreateGenerateTemplateScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractCreateTemplatePath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractSetupAccountScript(nonfungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractSetupAccountPath)),
		nonfungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaSetupAdminAccountScript(nonfungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractSetupAdminAccountPath)),
		nonfungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractAddAdminCapabilityScript(nonfungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractSelfAddAdminCapabilityPath)),
		nonfungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractAddNewAdminCapabilityScript(nonfungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractAddAdminCapabilityPath)),
		nonfungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractTransferNFTScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractTransferTokensPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func NFTContractDestroyNFTScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractDestroyTokensPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func TriQuetaMintTokensScript(fungibleAddr, TriQuetaAddr flow.Address) []byte {
	return TriQuetaReplaceAddressPlaceholders(
		string(readFile(NFTContractMintTokensPath)),
		fungibleAddr.String(),
		TriQuetaAddr.String(),
	)
}

func CheckCapabilityTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
) {
	tx := flow.NewTransaction().
		SetScript(CapabilityAccessScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func NFTContractCreateBrandTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	brandName string,
	metaData cadence.Dictionary,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaCreateGenerateCollectionScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	brand, _ := cadence.NewString(brandName)

	_ = tx.AddArgument(brand)    // brandName
	_ = tx.AddArgument(metaData) // Metadata

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func NFTContractUpdateBrandTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	brandId int,
	brandNameToUpdate string,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaUpdateBrandScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	brand := cadence.UInt64(uint64(brandId))

	_ = tx.AddArgument(brand) // brandName
	_ = tx.AddArgument(CadenceString(brandNameToUpdate))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func CreateSchema_Transaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	schemaName string,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaCreateGenerateSchemaScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)
	schema, _ := cadence.NewString(schemaName)

	_ = tx.AddArgument(schema)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func TriQuetaCreateTemplateTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	collectionId uint64,
	schemaId uint64,
	maxSupply uint64,
	metadata []cadence.KeyValuePair,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaCreateGenerateTemplateScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	_ = tx.AddArgument(cadence.NewUInt64(collectionId))
	_ = tx.AddArgument(cadence.NewUInt64(schemaId))
	_ = tx.AddArgument(cadence.NewUInt64(maxSupply))
	_ = tx.AddArgument(cadence.NewDictionary(metadata))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func TriQuetaMintTemplateTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	templateId uint64,
	receiverAccount sdk.Address,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaMintTokensScript(fungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	_ = tx.AddArgument(cadence.NewUInt64(templateId))
	_ = tx.AddArgument(cadence.NewAddress(receiverAccount))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func NFTContractSetupAccount(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	TriQuetaAddr sdk.Address,
	shouldFail bool,
) (sdk.Address, crypto.Signer) {
	accountKeys := test.AccountKeyGenerator()
	AccountKey, Signer := accountKeys.NewWithSigner()
	address, _ := emulator.CreateAccount([]*sdk.AccountKey{AccountKey}, nil)

	tx := flow.NewTransaction().
		SetScript(NFTContractSetupAccountScript(nonfungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(address)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, address},
		[]crypto.Signer{emulator.ServiceKey().Signer(), Signer},
		false,
	)

	return address, Signer
}

func GenerateAddress(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	TriQuetaAddr sdk.Address,
	shouldFail bool,
) sdk.Address {
	accountKeys := test.AccountKeyGenerator()
	AccountKey, _ := accountKeys.NewWithSigner()
	address, _ := emulator.CreateAccount([]*sdk.AccountKey{AccountKey}, nil)

	return address
}

func NFTContractTransferNFT(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	TriQuetaAddr sdk.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	recieverAddress sdk.Address,
	NFTId uint64,
) {

	tx := flow.NewTransaction().
		SetScript(NFTContractTransferNFTScript(nonfungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)
	_ = tx.AddArgument(cadence.NewAddress(recieverAddress))
	_ = tx.AddArgument(cadence.NewUInt64(NFTId))
	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		false,
	)

}

func NFTContractDestroyNFT(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	TriQuetaAddr sdk.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	NFTId uint64,
) {

	tx := flow.NewTransaction().
		SetScript(NFTContractDestroyNFTScript(nonfungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)
	_ = tx.AddArgument(cadence.NewUInt64(NFTId))
	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		false,
	)

}

func NFTContractSetupNewAdminAccount(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	TriQuetaAddr sdk.Address,
	shouldFail bool,
) (sdk.Address, crypto.Signer) {
	accountKeys := test.AccountKeyGenerator()
	AccountKey, Signer := accountKeys.NewWithSigner()
	address, _ := emulator.CreateAccount([]*sdk.AccountKey{AccountKey}, nil)

	tx := flow.NewTransaction().
		SetScript(TriQuetaSetupAdminAccountScript(nonfungibleAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(address)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, address},
		[]crypto.Signer{emulator.ServiceKey().Signer(), Signer},
		false,
	)

	return address, Signer
}

func NFTContractSetupAdminAccount(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	nftContractAddr sdk.Address,
	shouldFail bool,
	adminAddress sdk.Address,
	Signer crypto.Signer,
) {

	tx := flow.NewTransaction().
		SetScript(TriQuetaSetupAdminAccountScript(nonfungibleAddr, nftContractAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(adminAddress)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, adminAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), Signer},
		false,
	)

	return
}

func NFTContractAddAdminCapability(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	NFTContractAddr sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	adminAddress sdk.Address,
) {

	tx := flow.NewTransaction().
		SetScript(NFTContractAddAdminCapabilityScript(nonfungibleAddr, NFTContractAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(NFTContractAddr)

	_ = tx.AddArgument(cadence.NewAddress(adminAddress))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, NFTContractAddr},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		false,
	)

	return
}

func NFTContractAddNewAdminCapability(
	testing *testing.T,
	emulator *emulator.Blockchain,
	nonfungibleAddr,
	NFTContractAddr sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	adminAddress sdk.Address,
) {

	tx := flow.NewTransaction().
		SetScript(NFTContractAddNewAdminCapabilityScript(nonfungibleAddr, NFTContractAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(NFTContractAddr)

	_ = tx.AddArgument(cadence.NewAddress(adminAddress))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, NFTContractAddr},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		false,
	)

	return
}

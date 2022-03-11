package test

import (
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
)

func TriQuetaContractDeployContracts(b *emulator.Blockchain, testing *testing.T) (flow.Address, flow.Address, flow.Address, crypto.Signer, sdk.Address) {
	// Create Admin Account
	accountKeys := test.AccountKeyGenerator()
	adminAccountKey, adminSigner := accountKeys.NewWithSigner()

	// Non Fungible Token Code
	nftCode := loadNonFungibleToken()
	nftAddr, err := b.CreateAccount(
		[]*flow.AccountKey{adminAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	require.NoError(testing, err)

	_, err = b.CommitBlock()
	assert.NoError(testing, err)
	address, err := b.CreateAccount([]*sdk.AccountKey{adminAccountKey}, nil)

	// Load NFTContract Code of TriQueta
	NFTContractCode := loadNFTContract(nftAddr.String())
	adminAddr, err := b.CreateAccount(
		[]*flow.AccountKey{adminAccountKey},
		[]templates.Contract{templates.Contract{
			Name:   "NFTContract",
			Source: string(NFTContractCode),
		}},
	)
	assert.NoError(testing, err)

	_, err = b.CommitBlock()
	assert.NoError(testing, err)
	TriQuetaCode := loadTriQuetaContract(nftAddr.String(), adminAddr.String())

	TriQuetaAddr, err := b.CreateAccount(
		[]*flow.AccountKey{adminAccountKey},
		[]templates.Contract{templates.Contract{
			Name:   "TriQuetaContract",
			Source: string(TriQuetaCode),
		}},
	)
	assert.NoError(testing, err)

	_, err = b.CommitBlock()
	assert.NoError(testing, err)

	return nftAddr, adminAddr, TriQuetaAddr, adminSigner, address
}

func TriQuetaCreateGenerateDropScript(fungibleAddr, nonFungibleAddr, TriQuetaContract flow.Address) []byte {
	return TriQuetaContractReplaceAddressPlaceholders(
		string(readFile(NFTContractCreateDropPath)),
		fungibleAddr.String(),
		nonFungibleAddr.String(),
		TriQuetaContract.String(),
	)
}

func TriQuetaPurchaseGenerateDropScript(fungibleAddr, nonFungibleAddr, TriQuetaContract flow.Address) []byte {
	return TriQuetaContractReplaceAddressPlaceholders(
		string(readFile(TriQuetaPurchaseDropPath)),
		fungibleAddr.String(),
		nonFungibleAddr.String(),
		TriQuetaContract.String(),
	)
}

func TriQuetaRemoveDropScript(fungibleAddr, nonFungibleAddr, TriQuetaContract flow.Address) []byte {
	return TriQuetaContractReplaceAddressPlaceholders(
		string(readFile(TriQuetaRemoveDropPath)),
		fungibleAddr.String(),
		nonFungibleAddr.String(),
		TriQuetaContract.String(),
	)
}

func TriQuetaCreateDropTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	NFTContractAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	dropId uint64,
	startDate string,
	endDate string,
	metadata []cadence.KeyValuePair,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaCreateGenerateDropScript(fungibleAddr, NFTContractAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	sDate, _ := cadence.NewUFix64(startDate)
	eDate, _ := cadence.NewUFix64(endDate)

	_ = tx.AddArgument(cadence.NewUInt64(dropId))
	_ = tx.AddArgument(sDate)
	_ = tx.AddArgument(eDate)
	_ = tx.AddArgument(cadence.NewDictionary(metadata))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func TriQuetaPurchaseDropTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	NFTContractAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	dropId uint64,
	templateId uint64,
	mintNumbers uint64,
	creator sdk.Address,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaPurchaseGenerateDropScript(fungibleAddr, NFTContractAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	Creator := cadence.NewAddress(creator)

	_ = tx.AddArgument(cadence.NewUInt64(dropId))
	_ = tx.AddArgument(cadence.NewUInt64(templateId))
	_ = tx.AddArgument(cadence.NewUInt64(mintNumbers))
	_ = tx.AddArgument(Creator)

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

func TriQuetaRemoveDropTransaction(
	testing *testing.T,
	emulator *emulator.Blockchain,
	fungibleAddr,
	NFTContractAddr,
	TriQuetaAddr flow.Address,
	userAddress sdk.Address,
	userSigner crypto.Signer,
	shouldFail bool,
	dropId uint64,
) {
	tx := flow.NewTransaction().
		SetScript(TriQuetaRemoveDropScript(fungibleAddr, NFTContractAddr, TriQuetaAddr)).
		SetGasLimit(100).
		SetProposalKey(emulator.ServiceKey().Address, emulator.ServiceKey().Index, emulator.ServiceKey().SequenceNumber).
		SetPayer(emulator.ServiceKey().Address).
		AddAuthorizer(userAddress)

	_ = tx.AddArgument(cadence.NewUInt64(dropId))

	signAndSubmit(
		testing, emulator, tx,
		[]flow.Address{emulator.ServiceKey().Address, userAddress},
		[]crypto.Signer{emulator.ServiceKey().Signer(), userSigner},
		shouldFail,
	)
}

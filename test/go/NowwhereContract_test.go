package test

import (
	"fmt"
	"regexp"
	"strconv"
	"testing"
	"time"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	emulator "github.com/onflow/flow-emulator"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/stretchr/testify/assert"
)

var TemplateIDforDrop = cadence.NewUInt64(one) // Metdata Template Field
var DropField, _ = cadence.NewString("1")      // Metdata Template Field

func Test_ContractTestDeployment(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, ownerAddr, _, _, _ := NowwhereContractDeployContracts(emulator, test)

	test.Run("Should have initialized Supply field zero correctly", func(test *testing.T) {
		supply := executeScriptAndCheck(test, emulator, NowwhereGenerateGetSupplyScript(nonfungibleAddr, ownerAddr), nil)
		var supplyOnitial uint64 = uint64(zero)
		assert.EqualValues(test, CadenceUInt64(supplyOnitial), supply)
	})

	test.Run("Should have initialized Supply field zero correctly", func(test *testing.T) {
		supply := executeScriptAndCheck(test, emulator, NowwhereGenerateGetSupplyScript(nonfungibleAddr, ownerAddr), nil)
		var supplyOnitial uint64 = uint64(zero)
		assert.EqualValues(test, CadenceUInt64(supplyOnitial), supply)
	})
}

// Description: Create Drop of template
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Created
// Test-case-type: Positive
func Test_Admin_CheckCapablity(test *testing.T) {
	emulator := newEmulator()
	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// 1st account(admin) configure
	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)
	//	CheckCapabilityTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, shouldNotFail)
}

// Description: Create Drop of template
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Created
// Test-case-type: Positive
func Test_CreateDrop_Success(test *testing.T) {
	emulator := newEmulator()
	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}
	// Unix Timestamp
	//time.Time to Unix Timestamp
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	endtUnix := time.Now().AddDate(0, 0, 3).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	// 1st account(admin) configure
	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})
}

// Description: Create two Drop of same template
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Created
// Test-case-type: Positive
func Test_CreateDrop_TwoDropswithSameTemplate(test *testing.T) {
	emulator := newEmulator()
	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}
	// Unix Timestamp
	//time.Time to Unix Timestamp
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	endtUnix := time.Now().AddDate(0, 0, 3).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)
	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		two,                     // drop ID
		startDate,               // start date
		endDate,                 // end date
		metadatatemplateforDrop, // templateInformation
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(two), templateCount)
	})
}

// Description: Create Drop of template with wrong Start Date
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop not Created
// Test-case-type: Negative
func Test_CreateDrop_withWrongStartDate(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//tNow :=  // Add

	//time.Time to Unix Timestamp
	// Subtract 1 Day
	starttUnix := time.Now().AddDate(0, 0, -1).Unix()
	// Add 3 Days
	endtUnix := time.Now().AddDate(0, 0, 3).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should now have initialized Drop correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})
}

// Description: Create Drop of template with wrong End Date(End date less than start date)
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop not Created
// Test-case-type: Negative
func Test_CreateDrop_withWrongEndDate(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 2 Day
	starttUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Add 1 Days
	endtUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should now have initialized Drop correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

}

// Description: Create Drop of template with wrong End Date(End date equal to start date)
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop not Created
// Test-case-type: Negative
func Test_CreateDrop_withSameDates(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//tNow :=  // Add

	//time.Time to Unix Timestamp
	// Add 2 Day
	starttUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Add 1 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should now have initialized Drop correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})
}

// Description: Create Drop of template two time with same ID
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Created only one
// Test-case-type: Negative
func Test_CreateDrop_Duplicate(test *testing.T) {
	emulator := newEmulator()
	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}
	// Unix Timestamp
	//time.Time to Unix Timestamp
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	endtUnix := time.Now().AddDate(0, 0, 3).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)
	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should not have initialized duplicate Drop:", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})
}

// Description: Create Drop with wrong template ID
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop not Created
// Test-case-type: Negative
func Test_CreateDrop_WithWrongTemplateID(test *testing.T) {
	emulator := newEmulator()
	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	DropField, _ := cadence.NewString("1") // Metdata Template Field
	// metadata first argument template ID and second its information
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: cadence.NewUInt64(two), Value: DropField}}
	// Unix Timestamp
	//time.Time to Unix Timestamp
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	endtUnix := time.Now().AddDate(0, 0, 3).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one,                     // drop ID
		startDate,               // start date
		endDate,                 // end date
		metadatatemplateforDrop, // template ID and related information
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})
}

// Description: Purchase Drop
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Purchased
// Test-case-type: Positive
func Test_PurchaseDrop_Success(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 0).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	// Set Admin Rights for creating collection, schema and template
	// Admin will give rights to this account
	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
	fmt.Println("count:", DropCount.ToGoValue())
	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64
	//	fmt.Println("DropCount:", DropCount[0])
	fmt.Printf("t1: %T\n", submatchall)
	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}

	NowwherePurchaseDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		latestdropID,         // drop ID
		one,                  // templateID
		one,                  // Mint numbers
		NowwhereContractAddr, // ownerAddress
	)
	test.Run("Should Mint Template correctly", func(test *testing.T) {
		MintCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetNFTAddressCountScript(nonfungibleAddr, NFTContractAddr),
			[][]byte{jsoncdc.MustEncode(cadence.Address(NowwhereContractAddr))})
		assert.EqualValues(test, CadenceInt(one), MintCount)
	})
}

// Description: Purchase Drop more that the required supply
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Not Purchased
// Test-case-type: Negative
func Test_PurchaseDrop_morethansupply(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)

	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64

	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}
	fmt.Println(latestdropID)
	NowwherePurchaseDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		latestdropID,         // drop ID
		one,                  // templateID
		three,                // Mint numbers
		NowwhereContractAddr, // ownerAddress
	)
	test.Run("Should Mint Template correctly", func(test *testing.T) {
		MintCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetNFTAddressCountScript(nonfungibleAddr, NFTContractAddr),
			[][]byte{jsoncdc.MustEncode(cadence.Address(NowwhereContractAddr))})
		assert.EqualValues(test, CadenceInt(zero), MintCount)
	})
}

// Description: Purchase Drop with zero Supply
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Not Purchased
// Test-case-type: Negative
func Test_PurchaseDrop_zerosupply(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)

	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64

	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}
	fmt.Println(latestdropID)
	NowwherePurchaseDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		latestdropID,         // drop ID
		one,                  // templateID
		zero,                 // Mint numbers
		NowwhereContractAddr, // ownerAddress
	)

	test.Run("Should Mint Template correctly", func(test *testing.T) {
		MintCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetNFTAddressCountScript(nonfungibleAddr, NFTContractAddr),
			[][]byte{jsoncdc.MustEncode(cadence.Address(NowwhereContractAddr))})
		assert.EqualValues(test, CadenceInt(zero), MintCount)
	})
}

// Description: Purchase Drop with Non existent Template
// Input: brandId, creator address, startdate, enddate and template as input
// Expected Output: Drop Not Purchased
// Test-case-type: Negative
func Test_PurchaseDrop_nonexistentTemplate(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)

	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64

	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}

	NowwherePurchaseDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		latestdropID,         // drop ID
		two,                  // templateID
		one,                  // Mint numbers
		NowwhereContractAddr, // ownerAddress
	)

	test.Run("Should Mint Template correctly", func(test *testing.T) {
		MintCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetNFTAddressCountScript(nonfungibleAddr, NFTContractAddr),
			[][]byte{jsoncdc.MustEncode(cadence.Address(NowwhereContractAddr))})
		assert.EqualValues(test, CadenceInt(zero), MintCount)
	})
}

// Description: Remove Drop
// Input: dropID
// Expected Output: Drop Removed
// Test-case-type: Positive
func Test_RemoveDrop_Success(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)

	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64

	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}
	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})
	NowwhereRemoveDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		latestdropID, // drop ID
	)
	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

}

// Description: Remove Drop
// Input: dropID
// Expected Output: Drop not Removed
// Test-case-type: Negative
func Test_RemoveDrop_NonExistingDrop(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereRemoveDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		one, // drop ID
	)
	test.Run("Should not have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

}

// Description: Remove Drop without having permission
// Input: dropID, accountNumber which didn't create Drop
// Expected Output: Drop Not Removed
// Test-case-type: Negative
func Test_RemoveDrop_WithoutPermission(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"

	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NowwhereContractAddr, // Authorizer(sign transaction)
		signer,
		shouldNotFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	DropCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropIdsScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)

	re := regexp.MustCompile("[0-9]+")
	submatchall := re.FindAllString(DropCount.String(), 1)
	var latestdropID uint64

	for _, element := range submatchall {
		latestdropID, _ = strconv.ParseUint(element, 10, 64)
	}
	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})
	NowwhereRemoveDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NFTContractAddr, // Authorizer(sign transaction)
		signer,
		shouldFail,
		latestdropID, // drop ID
	)
	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(one), templateCount)
	})
}

// Description: Remove Drop without having permission(Who didn't create Template, schema and collection)
// Input: dropID, accountNumber which didn't create Drop
// Expected Output: Drop Not Created
// Test-case-type: Negative
func Test_CreateDrop_WithoutPermission(test *testing.T) {
	emulator := newEmulator()

	nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, _ := NowwhereContractDeployContracts(emulator, test)
	// Metdata Template Field

	// metadata
	metadatatemplateforDrop := []cadence.KeyValuePair{{Key: TemplateIDforDrop, Value: DropField}}

	//time.Time to Unix Timestamp
	// Add 0 Day
	starttUnix := time.Now().AddDate(0, 0, 1).Unix()
	// Add 2 Days
	endtUnix := time.Now().AddDate(0, 0, 2).Unix()
	// Unix Timestamp
	startDate := strconv.FormatInt(starttUnix, 10) + ".0"
	endDate := strconv.FormatInt(endtUnix, 10) + ".0"
	SetupAdminAndGiveCapabilityNowwhere(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	CreateBrandSchemaTemplateTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, shouldNotFail, signer)

	test.Run("Should have initialized Drop with zero correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

	NowwhereCreateDropTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		NFTContractAddr, // Authorizer(sign transaction with NFTContract Address who didn't create Template(Who Created NFTContract Address))
		signer,
		shouldFail,
		one,
		startDate,
		endDate,
		metadatatemplateforDrop,
	)

	test.Run("Should have initialized Drop with one correctly", func(test *testing.T) {
		templateCount := executeScriptAndCheck(test, emulator, NowwhereGenerateGetDropCountScript(nonfungibleAddr, NFTContractAddr, NowwhereContractAddr), nil)
		assert.EqualValues(test, CadenceInt(zero), templateCount)
	})

}

// Give capability to user after account setup
//nonfungibleAddr, NFTContractAddr, NowwhereContractAddr
func SetupAdminAndGiveCapabilityNowwhere(test *testing.T, emulator *emulator.Blockchain,
	nonfungibleAddr flow.Address, NFTContractAddr flow.Address, NowwhereAddress flow.Address, shouldNotFail bool, signer crypto.Signer) {
	NFTContractSetupAdminAccount(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		shouldNotFail,
		NowwhereAddress, // setup Admin account to that address
		signer,          // Signer of Admin Account
	)

	NFTContractAddNewAdminCapability(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		signer,
		shouldNotFail,
		NowwhereAddress, // setup Admin account to that address
	)
}

func CreateBrandSchemaTemplateTransaction(test *testing.T, emulator *emulator.Blockchain, nonfungibleAddr flow.Address, NFTContractAddr flow.Address, NowwhereContractAddr flow.Address, shouldNotFail bool, signer crypto.Signer) {
	/// Create Brand, schema and template
	brandNameField, _ := cadence.NewString(BrandMetadataKey)
	brandName, _ := cadence.NewString(BrandMetadataValue)
	metadata := []cadence.KeyValuePair{{Key: brandNameField, Value: brandName}}
	brandMetadata := cadence.NewDictionary(metadata)
	TemplateField, _ := cadence.NewString(SchemaName) // Metdata Template Field

	NFTContractCreateBrandTransaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, shouldNotFail, BrandName, brandMetadata)
	CreateSchema_Transaction(test, emulator, nonfungibleAddr, NFTContractAddr, NowwhereContractAddr, signer, shouldNotFail, SchemaName)
	// metadata
	metadatatemplate := []cadence.KeyValuePair{{Key: TemplateField, Value: TemplateField}}
	// Create Template Transaction  with brand ID:1 and schema ID:1 and 2 max Supply
	NowwhereCreateTemplateTransaction(
		test,
		emulator,
		nonfungibleAddr,
		NFTContractAddr,
		NowwhereContractAddr,
		signer,
		shouldNotFail,
		one, // brand ID
		one, // Schema ID
		two, // Max Supply
		metadatatemplate)

}

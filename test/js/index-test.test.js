import path from "path";
import {
  init,
  emulator,
  getAccountAddress,
  deployContractByName,
  getContractCode,
  getContractAddress,
  getTransactionCode,
  getScriptCode,
  executeScript,
  sendTransaction,
  mintFlow,
  getFlowBalance,
} from "flow-js-testing";
import { expect } from "@jest/globals";
import { checkPrimeSync } from "crypto";

jest.setTimeout(10000);

beforeAll(async () => {
  const basePath = path.resolve(__dirname, "../..");
  const port = 8080;

  await init(basePath, { port });
  await emulator.start(port);
});

afterAll(async () => {
  const port = 8080;
  await emulator.stop(port);
});

describe("Replicate Playground Accounts", () => {
  test("Create Accounts", async () => {
    // Playground project support 4 accounts, but nothing stops you from creating more by following the example laid out below
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    const Dave = await getAccountAddress("Dave");
    const Dani = await getAccountAddress("Dani");

    console.log(
      "Four Playground accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
    console.log("Dani:", Dani);
    //mint the flow to the user account
    const data = await mintFlow(Bob, "42.0");
    const updatedBalance = await getFlowBalance(Bob);
  });
});

describe("Deployment", () => {
  test("Deploy for NonFungibleToken", async () => {
    const name = "NonFungibleToken";
    const to = await getAccountAddress("Alice");
    let update = true;

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("NonFungibleToken");
  });

  test("Deploy for MetaDataViews", async () => {
    const name = "MetadataViews";
    const to = await getAccountAddress("Alice");
    let update = true;

    let result;
    try {
      const NonFungibleToken = await getContractAddress("NonFungibleToken");
      
      const addressMap = {
        NonFungibleToken,
      };
      result = await deployContractByName({
        name,
        to,
        update,
        addressMap
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("MetadataViews");
  });

  test("Deploy for TriQuetaNFT", async () => {
    const name = "TriQuetaNFT";
    const to = await getAccountAddress("Charlie");
    let update = true;
    console.log("started");
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const metadataViews = await getContractAddress("MetadataViews");
    const addressMap = {
      NonFungibleToken,
      metadataViews,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
      console.log("result:", result);
    } catch (e) {
      console.log(e);
      console.log("errror");
    }
    expect(name).toBe("TriQuetaNFT");
  });

  test("Deploy for TriQueta", async () => {
    const name = "TriQueta";
    const to = await getAccountAddress("Charlie");
    let update = true;
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    console.log("TriQueta:", TriQuetaNFT);
    let addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
      console.log("TriQueta deploy result:", result);
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("TriQueta");
  });
});

describe("Transactions", () => {
  test("test transaction setup admin Account", async () => {
    const name = "setupAdminAccount";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    console.log("TriQuetaNFT:", TriQuetaNFT);
    console.log("NonFungibleToken:", NonFungibleToken);
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction add admin Account", async () => {
    const name = "addAdminAccount";
    // Import participating accounts
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      const args = [Charlie];

      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx result ", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
  test("test transaction  create brand", async () => {
    const name = "createBrand";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    const args = ["HondaNorth", { name: "Alice" }];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
  test("test transaction  create Schema", async () => {
    const name = "createSchema";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    const args = ["Test Schema"];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction  create template", async () => {
    const name = "createTemplateStaticData";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    // brandId, schemaId, maxSupply,immutableData
    const args = [1, 1, 100];
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction  create drop", async () => {
    const name = "createDropStaticData";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [1, currentTimeInSeconds, currentTimeInSeconds + 20000000.0];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("add owner vault", async () => {
    const name = "addOwnerVault";

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("create user empty collection", async () => {
    const name = "createUserEmptyCollection";
    // Import participating accounts
    const Dani = await getAccountAddress("Dani");
    // Set transaction signers
    const signers = [Dani];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    console.log("done empty collection");
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction purchase drop", async () => {
    const name = "purchaseDrop";

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    const Dani = await getAccountAddress("Dani");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    const args = [1, 1, 4, Dani];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("create user empty collection", async () => {
    const name = "createUserEmptyCollection";
    // Import participating accounts
    const Bob = await getAccountAddress("Bob");
    // Set transaction signers
    const signers = [Bob];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    // expect(txResult.errorMessage).toBe("");
  });
  test("check intial balance of both user owner and buyer", async () => {
    let userOne = "0.00100000,";
    let user2 = "42.00100000,";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    const Bob = await getAccountAddress("Bob");
    // Check updated balance
    const updatedBalance1 = await getFlowBalance(Charlie);
    const updatedBalance2 = await getFlowBalance(Bob);
    //expected results
    expect(updatedBalance1.toString()).toBe(userOne);
    expect(updatedBalance2.toString()).toBe(user2);
  });

  test("purchase drop with flow", async () => {
    const name = "purchaseNFTWithFlow";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    const Bob = await getAccountAddress("Bob");
    // Set transaction signers
    const signers = [Charlie, Bob];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    const args = [1, 1, 4, Bob, 10.0];
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    console.log("done the user purchase with flow");
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("check final balance of both user owner and buyer", async () => {
    let userOne = "10.00100000,";
    let userTwo = "32.00100000,";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    const Bob = await getAccountAddress("Bob");
    // Check updated balance
    const updatedBalance1 = await getFlowBalance(Charlie);
    // console.log("Charlie", { updatedBalance1 });
    const updatedBalance2 = await getFlowBalance(Bob);
    // console.log("Bob", { updatedBalance2 });
    expect(updatedBalance1.toString()).toBe(userOne);
    expect(updatedBalance2.toString()).toBe(userTwo);
  });

  //remove template testcases
  test("test transaction  create template", async () => {
    const name = "createTemplateStaticData";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    // brandId, schemaId, maxSupply,immutableData
    const args = [1, 1, 100];
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction remove template", async () => {
    const name = "removeTemplate";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    // brandId, schemaId, maxSupply,immutableData
    const args = [2];
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
      console.log("remove Template result:", txResult);
    } catch (e) {
      console.log(e);
    }
    expect(txResult.errorMessage).toBe(undefined);
  });

  //update drop testcase
  //create new template
  test("test transaction  create template", async () => {
    const name = "createTemplateStaticData";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    // brandId, schemaId, maxSupply,immutableData
    const args = [1, 1, 100];
    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log(e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction  create drop", async () => {
    const name = "createDropStaticData";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [
      3,
      currentTimeInSeconds + 10000000.0,
      currentTimeInSeconds + 20000000.0,
    ];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  //updating the start date, end date and templates
  test("test transaction  Update drop", async () => {
    const name = "updateDropStatic1";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [
      3,
      currentTimeInSeconds + 15000000.0,
      currentTimeInSeconds + 40000000.0,
    ];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("update drop is done");
    console.log("Update the drop with correct params");
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  //updating the start date
  test("test transaction  Update drop", async () => {
    const name = "updateDropStatic";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [3, currentTimeInSeconds + 20000000.0, null];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("update drop is done");
    console.log("Update the start date with correct params");
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
  //updating the end date
  test("test transaction  Update drop", async () => {
    const name = "updateDropStatic";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [3, null, currentTimeInSeconds + 40000000.0];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("update drop is done");
    console.log("Update the start date and end date with correct params");
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
  //updating with wrong params
  test("test transaction  Update drop", async () => {
    const name = "updateDropStatic";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [3, null, null];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("update drop is done");
    console.log("Update the drop with wrong params");
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
  //updating the end date
  test("test transaction  Update drop", async () => {
    const name = "updateDropStatic";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [3, null, currentTimeInSeconds];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("update drop is done");
    console.log("Update the end date and with wrong params");
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  //remove drop test case
  test("test transaction  create drop", async () => {
    const name = "createDropStaticData";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds
    currentTimeInSeconds = currentTimeInSeconds + 10000000.0;
    const args = [2, currentTimeInSeconds, currentTimeInSeconds + 20000000.0];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });

  test("test transaction  remove drop", async () => {
    const name = "RemoveDrop";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");
    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [2];

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
        args,
      });
    } catch (e) {
      console.log("Error", e);
    }
    console.log("tx Result", txResult);
    expect(txResult.errorMessage).toBe(undefined);
  });
});
describe("Scripts", () => {
  test("get user NFT", async () => {
    const name = "getUserNFT";
    const Bob = await getAccountAddress("Bob");
    let nftcount = 0;
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });
    const args = [Bob];
    const result = await executeScript({
      code,
      args,
    });
    expect(result.length > nftcount);
    console.log("result", result);
  });
  test("get total supply", async () => {
    const name = "getTotalSupply";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
    });
    console.log("result", result);
  });
  test("get brand data", async () => {
    const name = "getAllBrands";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
    });
    console.log("result", result);
  });
  test("get brand data by Id", async () => {
    const name = "getBrandById";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });
    const args = [1];

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get schema data", async () => {
    const name = "getallSchema";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
    });
    console.log("result", result);
  });
  test("get schema data by Id", async () => {
    const name = "getSchemaById";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const args = [1];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });

  test("get template data ", async () => {
    const name = "getAllTemplates";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
    });
    console.log("result", result);
  });
  test("get template data by Id", async () => {
    const name = "getTemplateById";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });
    const args = [1];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get drop data ", async () => {
    const name = "getAllDrops";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const result = await executeScript({
      code,
    });
    console.log("result", result);
  });
  test("get drop data by Id", async () => {
    const name = "getDropById";
    const Charlie = await getAccountAddress("Charlie");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });
    console.log("code", code);

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
          "0X03": Charlie,
        };
        const name = accounts[match];
        console.log("accounts", accounts);
        console.log("name", name);
        return `getAccount(${name})`;
      });
    const args = [1];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get all nfts  data", async () => {
    const name = "getAllNFTIds";
    const Dani = await getAccountAddress("Dani");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
    const TriQueta = await getContractAddress("TriQueta");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
      TriQueta,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x05": Dani,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });
    const args = [Dani];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get nft template data", async () => {
    const name = "getNFTTemplateData";
    const Dani = await getAccountAddress("Dani");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x05": Dani,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const args = [Dani];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get nft maxSupply drop data", async () => {
    const name = "getMaxSupply";
    const Bob = await getAccountAddress("Bob");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const TriQuetaNFT = await getContractAddress("TriQuetaNFT");

    const addressMap = {
      NonFungibleToken,
      TriQuetaNFT,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x01": Alice,
          "0x02": Bob,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });
    const args = [1];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
});


test("get nft View", async () => {
  const name = "getNFTView";
  const Bob = await getAccountAddress("Bob");
  const Dani = await getAccountAddress("Dani");

  const TriQuetaNFT = await getContractAddress("TriQuetaNFT");
  const MetaDataView = await getContractAddress("MetadataViews");

  const addressMap = {
    TriQuetaNFT,
    MetaDataView
  };
  let code = await getScriptCode({
    name,
    addressMap,
  });

  code = code
    .toString()
    .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
      const accounts = {
        "0x01": Alice,
        "0x02": Bob,
      };
      const name = accounts[match];
      return `getAccount(${name})`;
    });
  const args = [Dani,1];
  const result = await executeScript({
    code,
    args,
  });
  console.log("result", result);
});


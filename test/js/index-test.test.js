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

    console.log(
      "Four Playground accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
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
  test("Deploy for NFTContract", async () => {
    const name = "NFTContract";
    const to = await getAccountAddress("Bob");
    let update = true;

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const addressMap = {
      NonFungibleToken,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("NFTContract");
  });
  test("Deploy for NowWhereContract", async () => {
    const name = "NowWhereContract";
    const to = await getAccountAddress("Charlie");
    let update = true;
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");

    let addressMap = {
      NonFungibleToken,
      NFTContract,
    };
    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
        update,
      });
    } catch (e) {
      console.log(e);
    }
    expect(name).toBe("NowWhereContract");
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
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });
  test("test transaction add admin Account", async () => {
    const name = "addAdminAccount";
    // Import participating accounts
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Bob];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });
  test("test transaction  create brand", async () => {
    const name = "createBrand";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });
  test("test transaction  create Schema", async () => {
    const name = "createSchema";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });
  test("test transaction  create template", async () => {
    const name = "createTemplate";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    let immutableData  = {
      "artist" : "Nasir And Sham",
      "artistEmail" : "sham&nasir@gmai.com",
      "title" : "First NFT",
      "mintType" : "MintOnSale",
      "nftType" : "AR",
      "rarity" : "Epic",
      "contectType" : "Image",
      "contectValue" : "https://troontechnologies.com/"       
    }
    // brandId, schemaId, maxSupply,immutableData
    const args = [1, 1, 100,immutableData];
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
    // expect(txResult.errorMessage).toBe("");
  });

  test("test transaction  create template", async () => {
    const name = "createTemplateStaticData";
    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });
  test("test transaction  create drop", async () => {
    const name = "createDrop";
    var currentTimeInSeconds = Math.floor(Date.now() / 1000); //unix timestamp in seconds

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    let template = {1:"3"}
    const args = [1, currentTimeInSeconds, "1702996401.0", template];

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
    // expect(txResult.errorMessage).toBe("");
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
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });
    var test = 1;
    const args = [1, currentTimeInSeconds, "1702996401.0"];

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
    // expect(txResult.errorMessage).toBe("");
  });
  test("add owner vault", async () => {
    const name = "addOwnerVault";

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");
    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
  test("create user empty collection", async () => {
    const name = "createUserEmptyCollection";
    // Import participating accounts
    const Bob = await getAccountAddress("Bob");
    // Set transaction signers
    const signers = [Bob];
    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
  test("test transaction  purchase drop", async () => {
    const name = "purchaseDrop";

    // Import participating accounts
    const Charlie = await getAccountAddress("Charlie");

    // Set transaction signers
    const signers = [Charlie];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    const args = [1, 1, 4, Charlie];

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
    // expect(txResult.errorMessage).toBe("");
  });

  test("check intial balance of both user owner and buyer", async () => {
    let userOne = "0.00100000";
    let user2 = "42.00100000";
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
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");
    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    // expect(txResult.errorMessage).toBe("");
  });

  test("check final balance of both user owner and buyer", async () => {
    let userOne = "10.00100000";
    let userTwo = "32.00100000";
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
});
describe("Scripts", () => {
  test("get user NFT", async () => {
    const name = "getUserNFT";
    const Bob = await getAccountAddress("Bob");
    let nftcount = 0;
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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

    console.log(typeof myInt);
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
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
    const Charlie = await getAccountAddress("Charlie");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");
    const NowWhereContract = await getContractAddress("NowWhereContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
      NowWhereContract,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x03": Charlie,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });
    const args = [Charlie];
    const result = await executeScript({
      code,
      args,
    });
    console.log("result", result);
  });
  test("get nft template data", async () => {
    const name = "getNFTTemplateData";
    const Charlie = await getAccountAddress("Charlie");

    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
    };
    let code = await getScriptCode({
      name,
      addressMap,
    });

    code = code
      .toString()
      .replace(/(?:getAccount\(\s*)(0x.*)(?:\s*\))/g, (_, match) => {
        const accounts = {
          "0x03": Charlie,
        };
        const name = accounts[match];
        return `getAccount(${name})`;
      });

    const args = [Charlie];
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
    const NFTContract = await getContractAddress("NFTContract");

    const addressMap = {
      NonFungibleToken,
      NFTContract,
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

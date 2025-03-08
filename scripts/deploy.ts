import hre from "hardhat";

// ============ Deployed Contracts ============
var CAF_TOKEN_ADDRESS = "0x05F0Af30AE7E2b3a3443Fa66d8B5aDCeAD44E396";
var CAF_CONTRACT_REGISTRY_ADDRESS = "0x0E451c3C83681f95bFb9ff32BAF25FE64A64c285"; // 
var CAF_GAME_MANAGER_ADDRESS = "0xE8BC8954eAd39D78A302d4f97115acc8bEd9C78b"; // v
var CAF_GAME_ECONOMY_ADDRESS = "0xE6B4917A122f30A0E79E8E5424bEFF31419DA793"; // v
var CAF_PRODUCT_ITEMS_ADDRESS = "0xE79AE574f393320A697b5Db5C942dae333b6Acc5"; // 
var CAF_COMPANY_ITEMS_ADDRESS = "0x98d9Ae1bc9f7D0C742f76D00f0406058F6d9c1fE"; // 
var CAF_EVENT_ITEMS_ADDRESS = "0xCFC9903e8776f731f59FCbbf2780EE96193F0FEA"; // v
var CAF_MATERIAL_FACTORY_ADDRESS = "0xb49f63DAF938F9da0aD821F88a71b50E06858f8E"; // 
var CAF_MARKETPLACE_ADDRESS = "0xF994326a542A780B142e126CC4282F6eDDc9F642"; // v
var CAF_POOL_FACTORY_CONTRACT_ADDRESS = "0x8fc45128D35Ee61D1e72F280d80156118072Cdd3"; // v
async function deployPart2() {
    try {
        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.deploy(CAF_CONTRACT_REGISTRY_ADDRESS)

        await cafToken.waitForDeployment();
        CAF_TOKEN_ADDRESS = await cafToken.getAddress();
        console.log("CAFToken deployed to:", CAF_TOKEN_ADDRESS);
    } catch (error) {
        console.log(error);
    }
}
async function deployPart1() {
    try {
        const CAFContractRegistry = await hre.ethers.getContractFactory("CAFContractRegistry");
        const cafContractRegistry = await CAFContractRegistry.deploy({
            gasLimit: 8000000,
        });

        await cafContractRegistry.waitForDeployment();
        CAF_CONTRACT_REGISTRY_ADDRESS = await cafContractRegistry.getAddress();
        console.log("CAFContractRegistry deployed to:", CAF_CONTRACT_REGISTRY_ADDRESS);

        const CAFGameManager = await hre.ethers.getContractFactory("CAFGameManager");
        const cafGameManager = await CAFGameManager.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafGameManager.waitForDeployment();
        CAF_GAME_MANAGER_ADDRESS = await cafGameManager.getAddress();
        console.log("CAFGameManager deployed to:", CAF_GAME_MANAGER_ADDRESS);

        const CAFGameEconomy = await hre.ethers.getContractFactory("CAFGameEconomy");
        const cafGameEconomy = await CAFGameEconomy.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafGameEconomy.waitForDeployment();
        CAF_GAME_ECONOMY_ADDRESS = await cafGameEconomy.getAddress();
        console.log("CAFGameEconomy deployed to:", CAF_GAME_ECONOMY_ADDRESS);

        const CAFProductItems = await hre.ethers.getContractFactory("CAFProductItems");
        const cafProductItems = await CAFProductItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafProductItems.waitForDeployment();
        CAF_PRODUCT_ITEMS_ADDRESS = await cafProductItems.getAddress();
        console.log("CAFProductItems deployed to:", CAF_PRODUCT_ITEMS_ADDRESS);

        const CAFCompanyItems = await hre.ethers.getContractFactory("CAFCompanyItems");
        const cafCompanyItems = await CAFCompanyItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafCompanyItems.waitForDeployment();
        CAF_COMPANY_ITEMS_ADDRESS = await cafCompanyItems.getAddress();
        console.log("CAFCompanyItems deployed to:", CAF_COMPANY_ITEMS_ADDRESS);

        const CAFEventItems = await hre.ethers.getContractFactory("CAFEventItems");
        const cafEventItems = await CAFEventItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafEventItems.waitForDeployment();
        CAF_EVENT_ITEMS_ADDRESS = await cafEventItems.getAddress();
        console.log("CAFEventItems deployed to:", CAF_EVENT_ITEMS_ADDRESS);

        const CAFMaterialFactory = await hre.ethers.getContractFactory("MaterialFactory");
        const cafMaterialFactory = await CAFMaterialFactory.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafMaterialFactory.waitForDeployment();
        CAF_MATERIAL_FACTORY_ADDRESS = await cafMaterialFactory.getAddress();
        console.log("CAFMaterialFactory deployed to:", CAF_MATERIAL_FACTORY_ADDRESS);

        const CAFPoolFactory = await hre.ethers.getContractFactory("CAFPoolFactory");
        const cafPoolFactory = await CAFPoolFactory.deploy();

        CAF_POOL_FACTORY_CONTRACT_ADDRESS = await cafPoolFactory.getAddress();
        console.log("CAFPoolFactory deployed to:", CAF_POOL_FACTORY_CONTRACT_ADDRESS);

        const CAFMarketplace = await hre.ethers.getContractFactory("CAFMarketplace");
        const cafMarketplace = await CAFMarketplace.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafMarketplace.waitForDeployment();
        CAF_MARKETPLACE_ADDRESS = await cafMarketplace.getAddress();
        console.log("CAFMarketplace deployed to:", CAF_MARKETPLACE_ADDRESS);
    } catch (error) {
        console.log(error);
    }
}

enum ContractRegistryType {
    CAF_TOKEN_CONTRACT,
    CAF_MARKETPLACE_CONTRACT,
    CAF_GAME_MANAGER_CONTRACT,
    CAF_GAME_ECONOMY_CONTRACT,
    CAF_MATERIAL_FACTORY_CONTRACT,
    CAF_COMPANY_ITEMS_CONTRACT,
    CAF_PRODUCT_ITEMS_CONTRACT,
    CAF_EVENT_ITEMS_CONTRACT,
    CAF_POOL_CONTRACT
}
async function setUpPart1() {
    try {

        const cafContractRegistry = await hre.ethers.getContractAt("CAFContractRegistry", CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafContractRegistry.registerContract(ContractRegistryType.CAF_MARKETPLACE_CONTRACT, CAF_MARKETPLACE_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_MANAGER_CONTRACT, CAF_GAME_MANAGER_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT, CAF_GAME_ECONOMY_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_PRODUCT_ITEMS_CONTRACT, CAF_PRODUCT_ITEMS_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_COMPANY_ITEMS_CONTRACT, CAF_COMPANY_ITEMS_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_EVENT_ITEMS_CONTRACT, CAF_EVENT_ITEMS_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_MATERIAL_FACTORY_CONTRACT, CAF_MATERIAL_FACTORY_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_POOL_CONTRACT, CAF_POOL_FACTORY_CONTRACT_ADDRESS);

        const cafGameManager = await hre.ethers.getContractAt("CAFGameManager", CAF_GAME_MANAGER_ADDRESS);
        await cafGameManager.setUp();

        const cafGameEconomy = await hre.ethers.getContractAt("CAFGameEconomy", CAF_GAME_ECONOMY_ADDRESS);
        await cafGameEconomy.setUp();

        const cafProductItems = await hre.ethers.getContractAt("CAFProductItems", CAF_PRODUCT_ITEMS_ADDRESS);
        await cafProductItems.setUp();

        const cafCompanyItems = await hre.ethers.getContractAt("CAFCompanyItems", CAF_COMPANY_ITEMS_ADDRESS);
        await cafCompanyItems.setUp();

        const cafEventItems = await hre.ethers.getContractAt("CAFEventItems", CAF_EVENT_ITEMS_ADDRESS);
        await cafEventItems.setUp();

        const cafMaterialFactory = await hre.ethers.getContractAt("MaterialFactory", CAF_MATERIAL_FACTORY_ADDRESS);
        await cafMaterialFactory.setUp();

        const cafMarketplace = await hre.ethers.getContractAt("CAFMarketplace", CAF_MARKETPLACE_ADDRESS);
        await cafMarketplace.setUp();
    } catch (error) {
        console.log(error);
    }
}

async function setUpAllPart2() {
    try {
        const cafMarketplace = await hre.ethers.getContractAt("CAFMarketplace", CAF_MARKETPLACE_ADDRESS);
        await cafMarketplace.setUp();
    } catch (error) {
        console.log(error);
    }
}
async function main() {
    await deployPart1();
    await setUpPart1();
    await deployPart2();
    await setUpAllPart2();
    console.log("All contracts deployed and set up successfully");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
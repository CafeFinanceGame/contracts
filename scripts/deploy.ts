import hre from "hardhat";

// ============ Deployed Contracts ============
var CAF_TOKEN_ADDRESS = "0x126D09D15A248DE2ab93E5EfbcD1E4e3A83a4240";
var CAF_CONTRACT_REGISTRY_ADDRESS = "0x371d51e2f322394B4963Bc628Fc163c0eD36AAE4"; // 
var CAF_GAME_MANAGER_ADDRESS = "0x0746C5E1380cC7B60c3f51955b9Df95e5353E89D"; // v
var CAF_GAME_ECONOMY_ADDRESS = "0xC62288658740a21DcB4a96FfDBdcC9Bad9133017"; // v
var CAF_PRODUCT_ITEMS_ADDRESS = "0x00b7DAFcA2893459c7491e9B39621baa05fc4FAD"; // v
var CAF_COMPANY_ITEMS_ADDRESS = "0x02030C575531a77531c98A7330CD6B197817702D"; // v
var CAF_EVENT_ITEMS_ADDRESS = "0x8B5b534c09026F4bf52f987DB8e82b8299bD778E"; // v
var CAF_MATERIAL_FACTORY_ADDRESS = "0xa076E1a6940Da910bd5fc040DAE069A6419c2850"; // v
var CAF_MARKETPLACE_ADDRESS = "0x995726E656A58132b757090c77e248A029f14428"; // v
var CAF_POOL_FACTORY_CONTRACT_ADDRESS = "0x8daf3E9e888fBA2a418F6D54D93074A7e6e2BEd8"; // v
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
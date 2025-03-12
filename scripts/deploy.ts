import hre from "hardhat";

// ============ Deployed Contracts ============
var CAF_CONTRACT_REGISTRY_ADDRESS = "0x6595f90Fb5555AD7b1a6d996b5182B55311dbf33"; // 
var CAF_GAME_MANAGER_ADDRESS = "0xD43EF0A8A95A7C8AEc64a460BD00f705Aff269b8"; // v
var CAF_GAME_ECONOMY_ADDRESS = "0xf86F8944B6b568ec69f1E63e192815E37B427b50"; // v
var CAF_ITEMS_MANAGER_CONTRACT_ADDRESS = "0x02dA1b4Db936F8F50e9f17E61F239c8091767b6A"; //
var CAF_MARKETPLACE_ADDRESS = "0xdDA62A83AFB1699f14e3AbD59D12b652Fd5Bd67C"; // v
var CAF_TOKEN_ADDRESS = "0xCAC1029C57a533d26BF782fC9560B0aA10d2fF7e";

async function deploy() {
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

        const CAFItemsManager = await hre.ethers.getContractFactory("CAFItemsManager")
        const cafItemsManager = await CAFItemsManager.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);
        await cafItemsManager.waitForDeployment();
        CAF_ITEMS_MANAGER_CONTRACT_ADDRESS = await cafItemsManager.getAddress();
        console.log("CAFItemsManager deployed to:", CAF_ITEMS_MANAGER_CONTRACT_ADDRESS);

        const CAFMarketplace = await hre.ethers.getContractFactory("CAFMarketplace");
        const cafMarketplace = await CAFMarketplace.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafMarketplace.waitForDeployment();
        CAF_MARKETPLACE_ADDRESS = await cafMarketplace.getAddress();
        console.log("CAFMarketplace deployed to:", CAF_MARKETPLACE_ADDRESS);

        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafToken.waitForDeployment();
        CAF_TOKEN_ADDRESS = await cafToken.getAddress();
        console.log("CAFToken deployed to:", CAF_TOKEN_ADDRESS);
    } catch (error) {
        console.log(error);
    }
}

enum ContractRegistryType {
    CAF_TOKEN_CONTRACT,
    CAF_GAME_MANAGER_CONTRACT,
    CAF_MARKETPLACE_CONTRACT,
    CAF_GAME_ECONOMY_CONTRACT,
    CAF_ITEMS_MANAGER_CONTRACT
}

async function setUp() {
    try {
        const cafContractRegistry = await hre.ethers.getContractAt("CAFContractRegistry", CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafContractRegistry.registerContract(ContractRegistryType.CAF_ITEMS_MANAGER_CONTRACT, CAF_ITEMS_MANAGER_CONTRACT_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_MARKETPLACE_CONTRACT, CAF_MARKETPLACE_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_MANAGER_CONTRACT, CAF_GAME_MANAGER_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT, CAF_GAME_ECONOMY_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_TOKEN_CONTRACT, CAF_TOKEN_ADDRESS);

        const cafItemsManager = await hre.ethers.getContractAt("CAFItemsManager", CAF_ITEMS_MANAGER_CONTRACT_ADDRESS);
        const cafMarketplace = await hre.ethers.getContractAt("CAFMarketplace", CAF_MARKETPLACE_ADDRESS);
        const cafGameManager = await hre.ethers.getContractAt("CAFGameManager", CAF_GAME_MANAGER_ADDRESS);
        const cafGameEconomy = await hre.ethers.getContractAt("CAFGameEconomy", CAF_GAME_ECONOMY_ADDRESS);
        const cafToken = await hre.ethers.getContractAt("CAFToken", CAF_TOKEN_ADDRESS);

        await cafItemsManager.setUp();
        await cafMarketplace.setUp();
        await cafGameManager.setUp();
        await cafGameEconomy.setUp();
        await cafToken.setUp();
        await cafToken.init();
    } catch (error) {
        console.log(error);
    }
}

async function deployPart2() {
    try {


        const cafContractRegistry = await hre.ethers.getContractAt("CAFContractRegistry", CAF_CONTRACT_REGISTRY_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_TOKEN_CONTRACT, CAF_TOKEN_ADDRESS);
    } catch (error) {
        console.log(error);
    }
}

async function main() {
    await deploy();
    await setUp();
    console.log("All contracts deployed and set up successfully");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
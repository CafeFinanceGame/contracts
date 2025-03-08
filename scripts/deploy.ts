import hre from "hardhat";

// ============ Deployed Contracts ============
var CAF_CONTRACT_REGISTRY_ADDRESS = "0xCf7ADc8bC1c6745E675b04281866a2B4a96201bC"; // 
var CAF_GAME_MANAGER_ADDRESS = "0x880279eec124EbEd2f50836482059F4Ed7d73061"; // v
var CAF_GAME_ECONOMY_ADDRESS = "0xAbb7a01B6C8490CBD4CB9B0Fc07DC4DdFab82BE0"; // v
var CAF_ITEMS_MANAGER_CONTRACT_ADDRESS = "0x343e17e9Bc8a5f548a621F143A33D5a2e0AdB3aA"; //
var CAF_MARKETPLACE_ADDRESS = "0x143732154690F75f25B93898a968ec9202726658"; // v
var CAF_TOKEN_ADDRESS = "0xD23e4c0afeCf96B122bc8f03BBa051E23168827F";

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

async function setUpPart1() {
    try {

        const cafContractRegistry = await hre.ethers.getContractAt("CAFContractRegistry", CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafContractRegistry.registerContract(ContractRegistryType.CAF_ITEMS_MANAGER_CONTRACT, CAF_ITEMS_MANAGER_CONTRACT_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_MARKETPLACE_CONTRACT, CAF_MARKETPLACE_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_MANAGER_CONTRACT, CAF_GAME_MANAGER_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT, CAF_GAME_ECONOMY_ADDRESS);

        const cafGameManager = await hre.ethers.getContractAt("CAFGameManager", CAF_GAME_MANAGER_ADDRESS);
        await cafGameManager.setUp();

        const cafGameEconomy = await hre.ethers.getContractAt("CAFGameEconomy", CAF_GAME_ECONOMY_ADDRESS);
        await cafGameEconomy.setUp();

        const cafItemsManager = await hre.ethers.getContractAt("CAFItemsManager", CAF_ITEMS_MANAGER_CONTRACT_ADDRESS);
        await cafItemsManager.setUp();


    } catch (error) {
        console.log(error);
    }
}

async function deployPart2() {
    try {
        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafToken.waitForDeployment();
        CAF_TOKEN_ADDRESS = await cafToken.getAddress();
        console.log("CAFToken deployed to:", CAF_TOKEN_ADDRESS);

        const cafContractRegistry = await hre.ethers.getContractAt("CAFContractRegistry", CAF_CONTRACT_REGISTRY_ADDRESS);
        await cafContractRegistry.registerContract(ContractRegistryType.CAF_TOKEN_CONTRACT, CAF_TOKEN_ADDRESS);
    } catch (error) {
        console.log(error);
    }
}

async function setUpAllPart2() {
    try {
        const cafMarketplace = await hre.ethers.getContractAt("CAFMarketplace", CAF_MARKETPLACE_ADDRESS);
        await cafMarketplace.setUp();

        const cafToken = await hre.ethers.getContractAt("CAFToken", CAF_TOKEN_ADDRESS);
        await cafToken.setUp();
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
import hre from "hardhat";

// ============ Deployed Contracts ============
const CAF_TOKEN_ADDRESS = "0x9AE7d73D68B0AeEc2357f4f81BCcA2304782d45d";
const CAF_CONTRACT_REGISTRY_ADDRESS = "0x7e4cbFb45Aec783883d9862629fA1caBb47869cb"; // 
const CAF_GAME_MANAGER_ADDRESS = "0xCF59ca97B73A2B10929CD5c8852e8e43b0bD92c2"; // v
const CAF_GAME_ECONOMY_ADDRESS = "0x2C7a3044F22e4171754F3746Cd63B58cDfAC4332"; // v
const CAF_PRODUCT_ITEMS_ADDRESS = "0x2bd61F952C6af056c50F15FB96b0982b0214Bf59"; // v
const CAF_COMPANY_ITEMS_ADDRESS = "0x615d1b78d3C7829183A300DCed40A25197cAB8ae"; // v
const CAF_EVENT_ITEMS_ADDRESS = "0xE0bCC9e1BC7639f806C4Fd7beDE4e45EAd5c55f6"; // v
const CAF_MATERIAL_FACTORY_ADDRESS = "0x5Cf621C7D625139f7D99551197522de749cC6D7b"; // v
const CAF_MARKETPLACE_ADDRESS = "0x57b38DeEE181456493026E9780A36B999dc24aA1"; // v

async function deployEconomicontracts() {
    try {
        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.deploy(CAF_CONTRACT_REGISTRY_ADDRESS)

        await cafToken.waitForDeployment();
        console.log("CAFToken deployed to:", await cafToken.getAddress());

        const CAFMarketplace = await hre.ethers.getContractFactory("CAFMarketplace");
        const cafMarketplace = await CAFMarketplace.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafMarketplace.waitForDeployment();
        console.log("CAFMarketplace deployed to:", await cafMarketplace.getAddress());

    } catch (error) {
        console.log(error);
    }
}
async function deployCoreContracts() {
    try {
        const CAFContractRegistry = await hre.ethers.getContractFactory("CAFContractRegistry");
        const cafContractRegistry = await CAFContractRegistry.deploy({
            gasLimit: 8000000,
        });

        await cafContractRegistry.waitForDeployment();
        console.log("CAFContractRegsitry deployed to:", await cafContractRegistry.getAddress());

        const CAFGameManager = await hre.ethers.getContractFactory("CAFGameManager");
        const cafGameManager = await CAFGameManager.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafGameManager.waitForDeployment();
        console.log("CAFGameManager deployed to:", await cafGameManager.getAddress());

        const CAFGameEconomy = await hre.ethers.getContractFactory("CAFGameEconomy");
        const cafGameEconomy = await CAFGameEconomy.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafGameEconomy.waitForDeployment();
        console.log("CAFGameEconomy deployed to:", await cafGameEconomy.getAddress());

        const CAFProductItems = await hre.ethers.getContractFactory("CAFProductItems");
        const cafProductItems = await CAFProductItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafProductItems.waitForDeployment();
        console.log("CAFProductItems deployed to:", await cafProductItems.getAddress());

        const CAFCompanyItems = await hre.ethers.getContractFactory("CAFCompanyItems");
        const cafCompanyItems = await CAFCompanyItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafCompanyItems.waitForDeployment();
        console.log("CAFCompanyItems deployed to:", await cafCompanyItems.getAddress());

        const CAFEventItems = await hre.ethers.getContractFactory("CAFEventItems");
        const cafEventItems = await CAFEventItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafEventItems.waitForDeployment();
        console.log("CAFEventItems deployed to:", await cafEventItems.getAddress());

        const CAFMaterialFactory = await hre.ethers.getContractFactory("MaterialFactory");
        const cafMaterialFactory = await CAFMaterialFactory.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafMaterialFactory.waitForDeployment();
        console.log("CAFMaterialFactory deployed to:", await cafMaterialFactory.getAddress());
    } catch (error) {
        console.log(error);
    }
}
async function main() {
    await deployCoreContracts();
    // await deployEconomicontracts();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
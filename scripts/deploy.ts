import hre from "hardhat";

// ============ Deployed Contracts ============
const CAF_TOKEN_ADDRESS = "0x9AE7d73D68B0AeEc2357f4f81BCcA2304782d45d";
const CAF_CONTRACT_REGISTRY_ADDRESS = "0xBe9eBf48DE05E12aa9B9A171A059539786C2FccF"; // Initialized
const CAF_GAME_MANAGER_ADDRESS = "0xc24C89DAfa4870A8EACBf2589A616f02eAAd4c5c"; // Initialized
const CAF_GAME_ECONOMY_ADDRESS = "0x41CEFeeA9cE818DC8c0f7dBE75D38E02b39Bc4Cb"; // Initializeds
const CAF_PRODUCT_ITEMS_ADDRESS = "0x74F464c1e21cEE4e360244A559e3489CB8cf6F60"; // Initialized
const CAF_COMPANY_ITEMS_ADDRESS = "0x5555eC0f39513964980f876A3160fC1951EC11E9";
const CAF_EVENT_ITEMS_ADDRESS = "0x3a326BA291E8656acD53AAE3383b9027B6353E1f";
const CAF_MARKETPLACE_ADDRESS = "0x57b38DeEE181456493026E9780A36B999dc24aA1"; // Initialized

async function deployEconomicontracts() {
    try {
        // const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        // const cafToken = await CAFToken.deploy(CAF_CONTRACT_REGISTRY_ADDRESS)

        // await cafToken.waitForDeployment();
        // console.log("CAFToken deployed to:", await cafToken.getAddress());

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
        // const CAFContractRegistry = await hre.ethers.getContractFactory("CAFContractRegistry");
        // const cafContractRegistry = await CAFContractRegistry.deploy({
        //     gasLimit: 8000000,
        // });

        // await cafContractRegistry.waitForDeployment();
        // console.log("CAFContractRegsitry deployed to:", await cafContractRegistry.getAddress());

        // const CAFGameManager = await hre.ethers.getContractFactory("CAFGameManager");
        // const cafGameManager = await CAFGameManager.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        // await cafGameManager.waitForDeployment();
        // console.log("CAFGameManager deployed to:", await cafGameManager.getAddress());

        // const CAFGameEconomy = await hre.ethers.getContractFactory("CAFGameEconomy");
        // const cafGameEconomy = await CAFGameEconomy.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        // await cafGameEconomy.waitForDeployment();
        // console.log("CAFGameEconomy deployed to:", await cafGameEconomy.getAddress());

        // const CAFProductItems = await hre.ethers.getContractFactory("CAFProductItems");
        // const cafProductItems = await CAFProductItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        // await cafProductItems.waitForDeployment();
        // console.log("CAFProductItems deployed to:", await cafProductItems.getAddress());

        // const CAFCompanyItems = await hre.ethers.getContractFactory("CAFCompanyItems");
        // const cafCompanyItems = await CAFCompanyItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        // await cafCompanyItems.waitForDeployment();
        // console.log("CAFCompanyItems deployed to:", await cafCompanyItems.getAddress());

        const CAFEventItems = await hre.ethers.getContractFactory("CAFEventItems");
        const cafEventItems = await CAFEventItems.deploy(CAF_CONTRACT_REGISTRY_ADDRESS);

        await cafEventItems.waitForDeployment();
        console.log("CAFEventItems deployed to:", await cafEventItems.getAddress());
    } catch (error) {
        console.log(error);
    }
}
async function main() {
    await deployEconomicontracts();
    // await deployCoreContracts();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
import hre from "hardhat";

// ============ Deployed Contracts ============
// CAFContractRegsitry: 0x0CfAe8A1f3D56439bBa4733BB16D8A96b4eA74E6
// CAFToken: 0xa34d09E2Cfc3F22CB77a9e4E81593Bb2b85c3002

async function deployEconomicontracts() {
    try {
        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.deploy();

        await cafToken.waitForDeployment();
        console.log("CAFToken deployed to:", await cafToken.getAddress());

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
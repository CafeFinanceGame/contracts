import hre from "hardhat";

// ============ Deployed Contracts ============
// CAFContractRegsitry: 0x3c4390fFE0C8fC13AA9d8F6c823285378a6D8649
// CAFToken: 0xa144150b6a812D5aA8E934ad65BAE1ae8F8dfA80

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
    // await deployEconomicontracts();
    await deployCoreContracts();
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
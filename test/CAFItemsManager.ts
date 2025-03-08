import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

enum ContractRegistryType {
    CAF_TOKEN_CONTRACT,
    CAF_GAME_MANAGER_CONTRACT,
    CAF_MARKETPLACE_CONTRACT,
    CAF_GAME_ECONOMY_CONTRACT,
    CAF_ITEMS_MANAGER_CONTRACT
}

enum ProductItemType {
    UNKNOWN,
    COFFEE_BEAN, // Default material product that only coffee company can import
    COFFEE, // Formula: Coffee Bean + Water + Kettle
    WATER, // Default material product that only material company can import
    MILK, // Formula: Water + Kettle
    MACHINE_MATERIAL, // Default material product that only machine company can import
    KETTLE // Formula: Machine Material + Water
}

describe("CAFItemsManager", function () {
    async function deployCAFItemsManagerFixture() {
        const [owner, otherAccount] = await hre.ethers.getSigners();

        const ContractRegistry = await hre.ethers.getContractFactory("CAFContractRegistry");
        const contractRegistry = await ContractRegistry.deploy();

        const CAFGameEconomy = await hre.ethers.getContractFactory("CAFGameEconomy");
        const cafGameEconomy = await CAFGameEconomy.deploy(await contractRegistry.getAddress());

        const CAFItemsManager = await hre.ethers.getContractFactory("CAFItemsManager");
        const cafItemsManager = await CAFItemsManager.deploy(await contractRegistry.getAddress());

        await contractRegistry.registerContract(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT, await cafGameEconomy.getAddress());
        await contractRegistry.registerContract(ContractRegistryType.CAF_ITEMS_MANAGER_CONTRACT, await cafItemsManager.getAddress());

        await cafItemsManager.setUp();

        return { cafItemsManager, contractRegistry, owner, otherAccount, cafGameEconomy };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { cafItemsManager, owner } = await loadFixture(deployCAFItemsManagerFixture);
            const ADMIN_ROLE = await cafItemsManager.ADMIN_ROLE();
            await cafItemsManager.grantRole(ADMIN_ROLE, await owner.getAddress());

            expect(await cafItemsManager.hasRole(ADMIN_ROLE, await owner.getAddress())).to.equal(true);
        });

        it("Should create a factory company item for the system", async function () {
            const { cafItemsManager } = await loadFixture(deployCAFItemsManagerFixture);

            const companyId = await cafItemsManager.getAllCompanyItemIds();
            expect(companyId.length).to.equal(1);

            const companyItem = await cafItemsManager.getCompanyItem(companyId[0]);

            expect(companyItem.owner).to.equal(await cafItemsManager.getAddress());
        });
    });

    describe("Company Items", function () {
        it("Should create a company item", async function () {
            const { cafItemsManager, owner } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // Assuming 1 is a valid CompanyType
            const companyIds = await cafItemsManager.getAllCompanyItemIds();
            expect(companyIds.length).to.equal(2);
            const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
            const companyItem = await cafItemsManager.getCompanyItem(companyId);
            expect(companyId).to.equal(2);
            expect(companyItem.owner).to.equal(owner.address);
            expect(companyItem.role).to.equal(1);
            expect(companyItem.energy).to.equal(100);
        });

        it("Should lost energy when do action", async function () {

        });
    })
    describe("Product Items", function () {
        it("Should create a product item", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // Assuming 1 is a valid CompanyType
            const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];

            const productType = 1;
            await cafItemsManager.createProductItem(companyId, productType); // Assuming 1 is a valid ProductItemType
            const productEconomy = await cafGameEconomy.getProductEconomy(productType);
            const productItemIds = await cafItemsManager.getAllProductItemIds();
            expect(productItemIds.length).to.equal(1);

            const productItem = await cafItemsManager.getProductItem(productItemIds[0]);
            expect(await cafItemsManager.balanceOf(owner.address, productItemIds[0])).to.equal(1);
            expect(productItem.productType).to.equal(1);
            expect(productItem.energy).to.equal(productEconomy.energy);
            expect(productItem.durability).to.equal(productEconomy.durability);
            expect(productItem.decayRatePerHour).to.equal(productEconomy.decayRatePerHour);
        });

        it("Should produce batch products items for contract manager", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // Assuming 1 is a valid CompanyType

            await time.increase(3600 + 1);

            const productType = 1;
            await cafItemsManager.produceProducts(productType, 10); // Assuming 1 is a valid ProductItemType
            const productItems = await cafItemsManager.getAllProductItemIds();

            expect(productItems.length).to.equal(10);
            for (let i = 0; i < productItems.length; i++) {
                const productItem = await cafItemsManager.getProductItem(productItems[i]);
                const productEconomy = await cafGameEconomy.getProductEconomy(productType);

                expect(await cafItemsManager.balanceOf(await cafItemsManager.getAddress(), productItems[i])).to.equal(1);
                expect(productItem.productType).to.equal(1);
                expect(productItem.energy).to.equal(productEconomy.energy);
                expect(productItem.durability).to.equal(productEconomy.durability);
                expect(productItem.decayRatePerHour).to.equal(productEconomy.decayRatePerHour);
            }
        });

        it("Should decay product items over time", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            // Tạo công ty
            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // 1 là CompanyType

            await time.increase(3600 + 1);

            const companyId = 1;

            await cafItemsManager.createProductItem(companyId, ProductItemType.COFFEE_BEAN);
            await cafItemsManager.createProductItem(companyId, ProductItemType.MACHINE_MATERIAL);

            const productItems = await cafItemsManager.getAllProductItemIds();
            expect(productItems.length).to.be.greaterThan(0);

            const coffeeBeanId = productItems[0];
            const machineId = productItems[1];

            let coffeeBean = await cafItemsManager.getProductItem(coffeeBeanId);
            let machine = await cafItemsManager.getProductItem(machineId);
            let energyBefore = coffeeBean.energy;
            let durabilityBefore = machine.durability;
            let expTime = machine.expTime;

            await time.increase(3600);

            await cafItemsManager.decay(coffeeBeanId);
            await cafItemsManager.decay(machineId);

            coffeeBean = await cafItemsManager.getProductItem(coffeeBeanId);
            machine = await cafItemsManager.getProductItem(machineId);

            let energyAfterOfCoffeeBean = coffeeBean.energy;
            let durabilityAfterOfMachine = machine.durability;
            expect(energyAfterOfCoffeeBean).to.be.lessThan(energyBefore);
            expect(durabilityAfterOfMachine).to.be.lessThan(durabilityBefore);

            await time.increase(3600 * 24 * 30 * 3);

            if (await time.latest() >= expTime) {
                expect(await cafItemsManager.balanceOf(owner.address, coffeeBeanId)).to.equal(0);
                expect(await cafItemsManager.balanceOf(owner.address, machineId)).to.equal(0);
            }
        });

        it("Should check metadata of product items", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // 1 là CompanyType

            const companyId = 1;

            await cafItemsManager.connect(owner).createProductItem(companyId, ProductItemType.COFFEE_BEAN);

            const productItemId = (await cafItemsManager.getAllProductItemIds())[0];

            expect(await cafItemsManager.uri(productItemId)).to.equal("https://cafigame.vercel.app/api/items/" + productItemId + ".json");
        });

        it("Should manufacture product (with available recipe)", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // 1 là CompanyType

            const companyId = 1;

            await cafItemsManager.createProductItem(companyId, ProductItemType.COFFEE_BEAN);
            await cafItemsManager.createProductItem(companyId, ProductItemType.WATER);
            await cafItemsManager.createProductItem(companyId, ProductItemType.KETTLE);

            const coffeeBeanId = (await cafItemsManager.getAllProductItemIds())[0];
            const waterId = (await cafItemsManager.getAllProductItemIds())[1];
            const kettleId = (await cafItemsManager.getAllProductItemIds())[2];

            let coffeeBean = await cafItemsManager.getProductItem(coffeeBeanId);
            let water = await cafItemsManager.getProductItem(waterId);
            let kettle = await cafItemsManager.getProductItem(kettleId);

            await time.increase(3600 * 2);

            await cafItemsManager.manufacture(ProductItemType.COFFEE, [coffeeBeanId, waterId, kettleId]);

            const coffeeId = (await cafItemsManager.getAllProductItemIds())[3];
            const coffee = await cafItemsManager.getProductItem(coffeeId);

            coffeeBean = await cafItemsManager.getProductItem(coffeeBeanId);
            water = await cafItemsManager.getProductItem(waterId);
            kettle = await cafItemsManager.getProductItem(kettleId);


            expect(await cafItemsManager.balanceOf(owner.address, coffeeId)).to.equal(1);
            expect(coffee.productType).to.equal(ProductItemType.COFFEE);

            // test when manufacture product with invalid recipe
            await expect(
                cafItemsManager.connect(owner).manufacture(ProductItemType.COFFEE, [coffeeBeanId, waterId])
            ).to.be.revertedWith("CAFItemsManager: Incorrect number of components");

            await expect(
                cafItemsManager.connect(owner).manufacture(ProductItemType.COFFEE, [coffeeBeanId, waterId, waterId])
            ).to.be.revertedWith("CAFItemsManager: Incorrect recipe");
        });

        it("Should consume product items", async function () {
            const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFItemsManagerFixture);

            await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // 1 là CompanyType

            const companyId = 2;

            await cafItemsManager.createProductItem(companyId, ProductItemType.COFFEE_BEAN);
            await cafItemsManager.createProductItem(companyId, ProductItemType.WATER);
            await cafItemsManager.createProductItem(companyId, ProductItemType.KETTLE);

            const coffeeBeanId = (await cafItemsManager.getAllProductItemIds())[0];
            const waterId = (await cafItemsManager.getAllProductItemIds())[1];
            const kettleId = (await cafItemsManager.getAllProductItemIds())[2];

            await time.increase(3600 * 2);

            await cafItemsManager.connect(owner).manufacture(ProductItemType.COFFEE, [coffeeBeanId, waterId, kettleId]);

            const coffeeId = (await cafItemsManager.getAllProductItemIds())[3];

            await time.increase(3600 * 2);

            await cafItemsManager.connect(owner).replenishEnergy(companyId, coffeeId);

            expect((await cafItemsManager.getCompanyItem(companyId)).energy).to.equal(100);
        });
    });

    describe("Event Items", function () {
        // it("Should create an event item", async function () {
        //   const { cafItemsManager } = await loadFixture(deployCAFItemsManagerFixture);

        //   await cafItemsManager.createEventItem(1, 0, 1000); // Assuming 1 is a valid EventItemType
        //   const eventItemIds = await cafItemsManager.getAllEventItemIds();

        //   expect(eventItemIds.length).to.equal(1);
        // });
    });
});

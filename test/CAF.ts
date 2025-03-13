import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";

import hre from "hardhat";

enum CompanyType {
    UNKNOWN,
    FACTORY_COMPANY, // Only system has role this
    COFFEE_COMPANY,
    MACHINE_COMPANY,
    MATERIAL_COMPANY
}

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

describe("All tests", function () {
    async function deployCAFFixture() {
        const [owner, otherAccount] = await hre.ethers.getSigners();

        const ContractRegistry = await hre.ethers.getContractFactory("CAFContractRegistry");
        const contractRegistry = await ContractRegistry.deploy();
        const contractRegistryAddress = await contractRegistry.getAddress();

        const CAFGameEconomy = await hre.ethers.getContractFactory("CAFGameEconomy");
        const cafGameEconomy = await CAFGameEconomy.deploy(contractRegistryAddress);

        const CAFItemsManager = await hre.ethers.getContractFactory("CAFItemsManager");
        const cafItemsManager = await CAFItemsManager.deploy(contractRegistryAddress);

        const CAFMarketplace = await hre.ethers.getContractFactory("CAFMarketplace");
        const cafMarketplace = await CAFMarketplace.deploy(contractRegistryAddress);

        const CAFGameManager = await hre.ethers.getContractFactory("CAFGameManager");
        const cafGameManager = await CAFGameManager.deploy(contractRegistryAddress);


        await contractRegistry.registerContract(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT, await cafGameEconomy.getAddress());
        await contractRegistry.registerContract(ContractRegistryType.CAF_ITEMS_MANAGER_CONTRACT, await cafItemsManager.getAddress());
        await contractRegistry.registerContract(ContractRegistryType.CAF_MARKETPLACE_CONTRACT, await cafMarketplace.getAddress());
        await contractRegistry.registerContract(ContractRegistryType.CAF_GAME_MANAGER_CONTRACT, await cafGameManager.getAddress());

        const CAFToken = await hre.ethers.getContractFactory("CAFToken");
        const cafToken = await CAFToken.connect(owner).deploy(await contractRegistry.getAddress());

        await contractRegistry.registerContract(ContractRegistryType.CAF_TOKEN_CONTRACT, await cafToken.getAddress());

        await cafItemsManager.setUp();
        await cafMarketplace.setUp();
        await cafGameManager.setUp();
        await cafGameEconomy.setUp();
        await cafToken.setUp();
        await cafToken.connect(owner).init();

        return { cafItemsManager, contractRegistry, cafGameEconomy, cafToken, cafMarketplace, owner, otherAccount };
    }


    describe("CAFItemsManager", function () {
        describe("Deployment", function () {
            it("Should set the right owner", async function () {
                const { cafItemsManager, owner } = await loadFixture(deployCAFFixture);
                const ADMIN_ROLE = await cafItemsManager.ADMIN_ROLE();
                await cafItemsManager.grantRole(ADMIN_ROLE, await owner.getAddress());

                expect(await cafItemsManager.hasRole(ADMIN_ROLE, await owner.getAddress())).to.equal(true);
            });

            it("Should create a factory company item for the system", async function () {
                const { cafItemsManager } = await loadFixture(deployCAFFixture);

                const companyId = await cafItemsManager.getAllCompanyItemIds();
                expect(companyId.length).to.equal(1);

                const companyItem = await cafItemsManager.getCompanyItem(companyId[0]);

                expect(companyItem.owner).to.equal(await cafItemsManager.getAddress());
            });

            // it("Should lost energy when do action", async function () {
            //     const { cafItemsManager, owner } = await loadFixture(deployCAFItemsManagerFixture);

            //     await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // Assuming 1 is a valid CompanyType

            //     const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
            //     const companyItem = await cafItemsManager.getCompanyItem(companyId);

            //     expect(companyItem.energy).to.equal(100);

            //     await time.increase(3600 + 1);

            //     // await cafItemsManager.connect(owner).doAction(companyId);

            //     const companyItemAfter = await cafItemsManager.getCompanyItem(companyId);

            //     expect(companyItemAfter.energy).to.be.lessThan(companyItem.energy);
            // });
        });

        describe("Company Items", function () {
            it("Should create a company item", async function () {
                const { cafItemsManager, owner } = await loadFixture(deployCAFFixture);

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
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

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
                expect(productItem.decayRatePerQuarterDay).to.equal(productEconomy.decayRatePerQuarterDay);

                const allProductItemsOfOwner = await cafItemsManager.getAllProductItemByOwner(owner.address);

                expect(allProductItemsOfOwner.length).to.equal(1);
            });


            it("Should produce batch products items for contract manager", async function () {
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

                await time.increase(3600 * 6);

                const productType = ProductItemType.WATER;
                const produceRatePerHour = 10;
                await cafItemsManager.produceProducts(productType, produceRatePerHour);
                const productItems = await cafItemsManager.getAllProductItemIds();

                expect(productItems.length).to.equal(10);
                for (let i = 0; i < productItems.length; i++) {
                    const productItem = await cafItemsManager.getProductItem(productItems[i]);
                    const productEconomy = await cafGameEconomy.getProductEconomy(productType);

                    expect(await cafItemsManager.balanceOf(await cafItemsManager.getAddress(), productItems[i])).to.equal(1);
                    expect(productItem.productType).to.equal(productType);
                    expect(productItem.energy).to.equal(productEconomy.energy);
                    expect(productItem.durability).to.equal(productEconomy.durability);
                    expect(productItem.decayRatePerQuarterDay).to.equal(productEconomy.decayRatePerQuarterDay);
                }

                // try create product with createProductItem after produceProducts
                await cafItemsManager.createProductItem(1, ProductItemType.WATER);
                const productItemIds = await cafItemsManager.getAllProductItemIds();
                expect(productItemIds.length).to.equal(11);

                const productItem = await cafItemsManager.getProductItem(productItemIds[10]);
                const productEconomy = await cafGameEconomy.getProductEconomy(ProductItemType.COFFEE_BEAN);

                expect(await cafItemsManager.balanceOf(await cafItemsManager.getAddress(), productItemIds[10])).to.equal(1);
                expect(productItem.productType).to.equal(ProductItemType.WATER);
                expect(productItem.energy).to.equal(productEconomy.energy);
                expect(productItem.durability).to.equal(productEconomy.durability);
            });

            it("Should decay product items over time", async function () {
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

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

                await time.increase(3600 * 6) // increase period to each 1 days / 4

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
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

                await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1); // 1 là CompanyType

                const companyId = 1;

                await cafItemsManager.connect(owner).createProductItem(companyId, ProductItemType.COFFEE_BEAN);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];

                expect(await cafItemsManager.uri(productItemId)).to.equal("https://cafigame.vercel.app/api/items/" + productItemId + ".json");
            });

            it("Should manufacture product (with available recipe)", async function () {
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

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
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

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

            it("Should auto produce product items", async function () {
                const { cafItemsManager, owner, cafGameEconomy } = await loadFixture(deployCAFFixture);

                // 3 productEconomy COFFEE_BEAN, WATER, MACHINE_MATERIAL
                const coffeeBeanEconomy = await cafGameEconomy.getManufacturedProduct(ProductItemType.COFFEE_BEAN);
                const waterEconomy = await cafGameEconomy.getManufacturedProduct(ProductItemType.WATER);
                const machineMaterialEconomy = await cafGameEconomy.getManufacturedProduct(ProductItemType.MACHINE_MATERIAL);

                const timePassed = 3600 * 6;
                await time.increase(timePassed);

                await cafItemsManager.autoProduceProducts();
                const expectedQuantity = Number(coffeeBeanEconomy[0]) + Number(waterEconomy[0]) + Number(machineMaterialEconomy[0]);

                const productItems = await cafItemsManager.getAllProductItemIds();
                expect(productItems.length).to.equal(expectedQuantity);

                await time.increase(timePassed * 4);

                await cafItemsManager.autoProduceProducts();

                const productItemsAfter = await cafItemsManager.getAllProductItemIds();
                expect(productItemsAfter.length).to.equal(expectedQuantity * 5);
            });
        });

        describe("Event Items", function () {
            it("Should create an event item", async function () {
                const { cafItemsManager } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createEventItem(1, 0, 1000); // Assuming 1 is a valid EventItemType
                const eventItemIds = await cafItemsManager.getAllEventItemIds();

                expect(eventItemIds.length).to.equal(1);
            });

            it("Should start an event", async function () {
                const { cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createEventItem(1, 0, (await time.latest()) + 1000); // Assuming 1 is a valid EventItemType
                const eventItemId = (await cafItemsManager.getAllEventItemIds())[0];

                const activeEvents = await cafItemsManager.getAllActiveEventItemIds();
                await cafItemsManager.startEvent(eventItemId);

                const eventItem = await cafItemsManager.getEventItem(eventItemId);
                expect(activeEvents.length).to.equal(1);
            });

            it("Should end an event", async function () {
                const { cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createEventItem(1, 0, (await time.latest()) + 1000); // Assuming 1 is a valid EventItemType
                const eventItemId = (await cafItemsManager.getAllEventItemIds())[0];

                await cafItemsManager.startEvent(eventItemId);

                await time.increase(1000);

                await cafItemsManager.endEvent(eventItemId);

                const activeEvents = await cafItemsManager.getAllActiveEventItemIds();
            });
        });
    });

    describe("CAFMarketplace", function () {
        describe("Listing and Buying Items", function () {
            it("Should list an item", async function () {
                const { cafMarketplace, cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createCompanyItem(owner.address, 1);
                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
                await cafItemsManager.createProductItem(companyId, 1);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];
                await cafMarketplace.connect(owner).list(productItemId, 100);

                const listedItem = await cafMarketplace.getListedItem(productItemId);
                expect(listedItem.price).to.equal(100);
                expect(listedItem.owner).to.equal(owner.address);
            });

            it("Should unlist an item", async function () {
                const { cafMarketplace, cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createCompanyItem(owner.address, 1);
                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
                await cafItemsManager.createProductItem(companyId, 1);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];
                await cafMarketplace.connect(owner).list(productItemId, 100);

                await cafMarketplace.connect(owner).unlist(productItemId);

                const listedItem = await cafMarketplace.getListedItem(productItemId);
                expect(listedItem.price).to.equal(0);

                const allListedItemIds = await cafMarketplace.getAllListedItemIds();
                expect(allListedItemIds.length).to.equal(0);
            });

            it("Should buy an item", async function () {
                const { cafMarketplace, cafItemsManager, cafToken, owner, otherAccount } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createCompanyItem(owner.address, 1);
                await cafItemsManager.createCompanyItem(otherAccount.address, 1);

                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
                await cafItemsManager.createProductItem(companyId, 1);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];
                await cafMarketplace.connect(owner).list(productItemId, 100);

                // Check list item
                const listedItem = await cafMarketplace.getListedItem(productItemId);
                expect(listedItem.price).to.equal(100);
                expect(listedItem.owner).to.equal(owner.address);

                await cafToken.mint(otherAccount.address, 100);

                await cafToken.connect(otherAccount).approve(await cafMarketplace.getAddress(), 100);
                await cafMarketplace.connect(otherAccount).buy(productItemId);

                expect(await cafItemsManager.balanceOf(otherAccount.address, productItemId)).to.equal(1);
                expect(await cafItemsManager.balanceOf(owner.address, productItemId)).to.equal(0);
            });
        });

        describe("Updating and Unlisting Items", function () {
            it("Should update the price of a listed item", async function () {
                const { cafMarketplace, cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.createCompanyItem(owner.address, CompanyType.COFFEE_COMPANY);
                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
                await cafItemsManager.createProductItem(companyId, 1);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];
                await cafMarketplace.connect(owner).list(productItemId, 100);

                await cafMarketplace.connect(owner).updatePrice(productItemId, 200);

                const listedItem = await cafMarketplace.getListedItem(productItemId);
                expect(listedItem.price).to.equal(200);
            });

            it("Should unlist an item", async function () {
                const { cafMarketplace, cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                await cafItemsManager.connect(owner).createCompanyItem(owner.address, 1);
                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];
                await cafItemsManager.createProductItem(companyId, 1);

                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];
                await cafMarketplace.connect(owner).list(productItemId, 100);

                await cafMarketplace.connect(owner).unlist(productItemId);

                const listedItem = await cafMarketplace.getListedItem(productItemId);
                expect(listedItem.price).to.equal(0);
                expect(listedItem.owner).to.equal("0x0000000000000000000000000000000000000000");
            });
        });

        describe("Resell", function () {
            it("Should resell an item", async function () {
                const { cafGameEconomy, cafMarketplace, cafItemsManager, cafToken, owner, otherAccount } = await loadFixture(deployCAFFixture);

                await cafItemsManager.connect(owner).createCompanyItem(owner.address, CompanyType.COFFEE_COMPANY);
                const companyId = (await cafItemsManager.getAllCompanyItemIds())[1];

                await cafItemsManager.createProductItem(companyId, ProductItemType.COFFEE);
                const productItemId = (await cafItemsManager.getAllProductItemIds())[0];

                const resellPrice = await cafMarketplace.calculateResalePrice(productItemId);

                // await cafMarketplace.connect(owner).list(productItemId, 100);

                // await cafToken.connect(otherAccount).approve(await cafMarketplace.getAddress(), 100);
                await cafToken.mint(otherAccount.address, 100);

                // await cafMarketplace.connect(otherAccount).buy(productItemId);
                const beforeBalance = await cafToken.balanceOf(owner.address);

                await cafMarketplace.connect(owner).resell(productItemId);

                const afterBalance = await cafToken.balanceOf(owner.address);

                expect(await cafItemsManager.balanceOf(owner.address, productItemId)).to.equal(0);
                expect(afterBalance - beforeBalance).to.equal(resellPrice);
            });
        });
        describe("Auto", function () {
            it("Should auto list an item", async function () {
                const { cafMarketplace, cafItemsManager, owner } = await loadFixture(deployCAFFixture);

                const produceRatePerQuarterDay = 3;
                const productType = ProductItemType.COFFEE_BEAN;

                await time.increase(3600 * 6);

                await cafItemsManager.produceProducts(productType, produceRatePerQuarterDay);

                await cafMarketplace.autoList();

                const listedItemIds = await cafMarketplace.getAllListedItemIds();
                expect(listedItemIds.length).to.equal(produceRatePerQuarterDay);

                // check owner listed item still be owned by contract items mangaer
                console.log("Owner", owner.address)
                for (let i = 0; i < produceRatePerQuarterDay; i++) {
                    const listedItem = await cafMarketplace.getListedItem(listedItemIds[i]);
                    expect(listedItem.owner).equal(await cafItemsManager.getAddress())
                }
            });
        });
    });
});
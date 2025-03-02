// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {CAFAccessControl} from "./CAFAccessControl.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";

contract CAFGameEconomy is ICAFGameEconomy, CAFAccessControl {
    /*
    ============================ 🌍 GAME STORY: GAME ECONOMY ============================

    ======================= 📌 All Possible Parameters of a Product =======================
    - Energy:         The energy of the product, only for consumable products.
    - Durability:     The durability of the product, only for machine products.
    - Decay Rate:     The rate of decay of the product.
    - Decay Period:   The period of decay of the product.
    - Last Decay Time:The last time the product decayed.
    - Price:          The price of the product.
    - Cost Price:     The base value of the product when it is produced.
    - Insurance Price:The cost of insuring the product during transportation.
    - Freight Price:  The shipping cost from the factory to the company.
    - manufacturedPerHour: The amount of product manufactured per hour.

    🏢 Coffee Company
    - Coffee Bean:
        + Energy: 50
        + Decay Rate: 1
        + Decay Period: 3 hours
        + Cost Price: 5 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF
        + Manufactured Per Hour: 10
    - Black Coffee:
        + Energy: 100
        + Decay Rate: 1
        + Decay Period: 2 hours
        + Cost Price: 10 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF
    - Milk Coffee:
        + Energy: 250
        + Decay Rate: 6
        + Decay Period: 1 hour
        + Cost Price: 20 CAF
        + Insurance Price: 3 CAF
        + Freight Price: 4 CAF

    🌱 Material Company (Raw Materials - Energy Decay)
    - Powered Milk:
        + Energy: 180
        + Decay Rate: 4
        + Decay Period: 1 hour
        + Cost Price: 9 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 2 CAF
        + Manufactured Per Hour: 20
    - Milk:
        + Energy: 120
        + Decay Rate: 3
        + Decay Period: 1 hour
        + Cost Price: 8 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 2 CAF
    - Water:
        + Energy: 30
        + Decay Rate: 1
        + Decay Period: 6 hours
        + Cost Price: 3
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF
        + Manufactured Per Hour: 30

    🛠️ Machine Company (Equipment - Durability Decay)
    - Material Machine:
        + Durability: 500
        + Decay Rate: 3
        + Decay Period: 1 hour
        + Cost Price: 50 CAF
        + Insurance Price: 5 CAF
        + Freight Price: 8 CAF
        + Manufactured Per Hour: 5
    - Kettle:
        + Durability: 400
        + Decay Rate: 2
        + Decay Period: 1 hour
        + Cost Price: 40 CAF
        + Insurance Price: 4 CAF
        + Freight Price: 6 CAF
    - Milk Frother:
        + Durability: 600
        + Decay Rate: 4
        + Decay Period: 1 hour
        + Cost Price: 60 CAF
        + Insurance Price: 6 CAF
        + Freight Price: 10 CAF
    */

    mapping(ItemLibrary.ProductItemType => ProductEconomy) public products;
    mapping(ItemLibrary.ProductItemType => ManufacturedProduct)
        public manufacturedProducts;

    constructor(address _contractRegistry) CAFAccessControl(_contractRegistry) {
        _initializeProducts();
    }

    function _initializeProducts() internal {
        products[ItemLibrary.ProductItemType.COFFEE_BEAN] = ProductEconomy(
            50,
            0,
            1,
            3 hours,
            5,
            1,
            1
        );
        products[ItemLibrary.ProductItemType.BLACK_COFFEE] = ProductEconomy(
            100,
            0,
            1,
            2 hours,
            10,
            1,
            1
        );
        products[ItemLibrary.ProductItemType.MILK_COFFEE] = ProductEconomy(
            250,
            0,
            6,
            1 hours,
            20,
            3,
            4
        );
        products[ItemLibrary.ProductItemType.POWDERED_MILK] = ProductEconomy(
            180,
            0,
            4,
            1 hours,
            9,
            1,
            2
        );

        products[ItemLibrary.ProductItemType.MILK] = ProductEconomy(
            120,
            0,
            3,
            1 hours,
            8,
            1,
            2
        );

        products[ItemLibrary.ProductItemType.WATER] = ProductEconomy(
            30,
            0,
            1,
            6 hours,
            3,
            1,
            1
        );

        products[ItemLibrary.ProductItemType.KETTLE] = ProductEconomy(
            0,
            400,
            2,
            1 hours,
            40,
            4,
            6
        );
        products[ItemLibrary.ProductItemType.MILK_FROTHER] = ProductEconomy(
            0,
            600,
            4,
            1 hours,
            60,
            6,
            10
        );

        products[ItemLibrary.ProductItemType.MACHINE_MATERIAL] = ProductEconomy(
            0,
            500,
            3,
            1 hours,
            50,
            5,
            8
        );

        manufacturedProducts[
            ItemLibrary.ProductItemType.COFFEE_BEAN
        ] = ManufacturedProduct(10);
        manufacturedProducts[
            ItemLibrary.ProductItemType.POWDERED_MILK
        ] = ManufacturedProduct(20);
        manufacturedProducts[
            ItemLibrary.ProductItemType.WATER
        ] = ManufacturedProduct(30);
        manufacturedProducts[
            ItemLibrary.ProductItemType.MACHINE_MATERIAL
        ] = ManufacturedProduct(5);
    }

    function updateProductEconomy(
        ItemLibrary.ProductItemType _productType,
        uint256 _energy,
        uint256 _durability,
        uint8 _decayRate,
        uint256 _decayPeriod,
        uint256 _costPrice,
        uint256 _insurancePrice,
        uint256 _freightPrice
    ) external override onlyRole(ADMIN_ROLE) returns (bool) {
        require(
            products[_productType].decayPeriod > 0,
            "Product does not exist"
        );

        products[_productType] = ProductEconomy(
            _energy,
            _durability,
            _decayRate,
            _decayPeriod,
            _costPrice,
            _insurancePrice,
            _freightPrice
        );

        return true;
    }

    function updateManufacturedProduct(
        ItemLibrary.ProductItemType _productType,
        uint256 _manufacturedPerHour
    ) external onlyRole(ADMIN_ROLE) override returns (bool) {
        require(
            manufacturedProducts[_productType].manufacturedPerHour > 0,
            "Product does not exist"
        );

        manufacturedProducts[_productType] = ManufacturedProduct(
            _manufacturedPerHour
        );

        return true;
    }

    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    ) external view override returns (ProductEconomy memory) {
        ProductEconomy memory _product = products[_productType];

        return _product;
    }

    function getManufacturedProduct(
        ItemLibrary.ProductItemType _productType
    ) external view override returns (ManufacturedProduct memory) {
        ManufacturedProduct memory _product = manufacturedProducts[
            _productType
        ];

        return _product;
    }
}

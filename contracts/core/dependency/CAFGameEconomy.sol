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

    🏢 Coffee Company
    - Black Coffee:
        + Energy: 100
        + Decay Rate: 1
        + Decay Period: 2 hours
        + Cost Price: 10 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF

    - Sugar Coffee:
        + Energy: 200
        + Decay Rate: 4
        + Decay Period: 1 hour
        + Cost Price: 15 CAF
        + Insurance Price: 2 CAF
        + Freight Price: 3 CAF

    - Espresso:
        + Energy: 150
        + Decay Rate: 3
        + Decay Period: 1 hour
        + Cost Price: 12 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 2 CAF

    - Milk Coffee:
        + Energy: 250
        + Decay Rate: 6
        + Decay Period: 1 hour
        + Cost Price: 20 CAF
        + Insurance Price: 3 CAF
        + Freight Price: 4 CAF

    🌱 Material Company (Raw Materials - Energy Decay)
    - Coffee Bean:
        + Energy: 50
        + Decay Rate: 1
        + Decay Period: 3 hours
        + Cost Price: 5 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF

    - Milk:
        + Energy: 120
        + Decay Rate: 3
        + Decay Period: 1 hour
        + Cost Price: 8 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 2 CAF

    - Sugar:
        + Energy: 180
        + Decay Rate: 4
        + Decay Period: 1 hour
        + Cost Price: 9 CAF
        + Insurance Price: 1 CAF
        + Freight Price: 2 CAF

    - Water:
        + Energy: 30
        + Decay Rate: 1
        + Decay Period: 6 hours
        + Cost Price: 3
        + Insurance Price: 1 CAF
        + Freight Price: 1 CAF

    🛠️ Machine Company (Equipment - Durability Decay)
    - Grinder:
        + Durability: 500
        + Decay Rate: 3
        + Decay Period: 1 hour
        + Cost Price: 50 CAF
        + Insurance Price: 5 CAF
        + Freight Price: 8 CAF

    - Kettle:
        + Durability: 400
        + Decay Rate: 2
        + Decay Period: 1 hour
        + Cost Price: 40 CAF
        + Insurance Price: 4 CAF
        + Freight Price: 6 CAF

    - Moka Pot:
        + Durability: 300
        + Decay Rate: 1
        + Decay Period: 1 hour
        + Cost Price: 30 CAF
        + Insurance Price: 3 CAF
        + Freight Price: 5 CAF

    - Milk Frother:
        + Durability: 600
        + Decay Rate: 4
        + Decay Period: 1 hour
        + Cost Price: 60 CAF
        + Insurance Price: 6 CAF
        + Freight Price: 10 CAF
    */

    struct ProductEconomy {
        uint256 energy;
        uint256 durability;
        uint8 decayRate;
        uint256 decayPeriod;
        uint256 costPrice;
        uint256 insurancePrice;
        uint256 freightPrice;
    }

    mapping(ItemLibrary.ProductItemType => ProductEconomy) public products;

    constructor(address _contractRegistry) CAFAccessControl(_contractRegistry) {
        _initializeProducts();
    }

    function _initializeProducts() internal {
        products[ItemLibrary.ProductItemType.BLACK_COFFEE] = ProductEconomy(
            100,
            0,
            1,
            2 hours,
            10,
            1,
            1
        );
        products[ItemLibrary.ProductItemType.SUGAR_COFFEE] = ProductEconomy(
            200,
            0,
            4,
            1 hours,
            15,
            2,
            3
        );
        products[ItemLibrary.ProductItemType.ESPRESSO] = ProductEconomy(
            150,
            0,
            3,
            1 hours,
            12,
            1,
            2
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
        products[ItemLibrary.ProductItemType.COFFEE_BEAN] = ProductEconomy(
            50,
            0,
            1,
            3 hours,
            5,
            1,
            1
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
        products[ItemLibrary.ProductItemType.SUGAR] = ProductEconomy(
            180,
            0,
            4,
            1 hours,
            9,
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
        products[ItemLibrary.ProductItemType.GRINDER] = ProductEconomy(
            0,
            500,
            3,
            1 hours,
            50,
            5,
            8
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
        products[ItemLibrary.ProductItemType.MOKA_POT] = ProductEconomy(
            0,
            300,
            1,
            1 hours,
            30,
            3,
            5
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
    ) external onlyRole(ADMIN_ROLE) returns (bool) {
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

    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    )
        external
        view
        override
        returns (uint256, uint256, uint8, uint256, uint256, uint256, uint256)
    {
        ProductEconomy memory _product = products[_productType];

        return (
            _product.energy,
            _product.durability,
            _product.decayRate,
            _product.decayPeriod,
            _product.costPrice,
            _product.insurancePrice,
            _product.freightPrice
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {IMaterialFactory} from "../interfaces/IMaterialFactory.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {CAFAccessControl} from "../dependency/CAFAccessControl.sol";

contract MaterialFactory is IMaterialFactory, CAFAccessControl {
    /*
    ============================ 🌍 GAME STORY: GAME ECONOMY ============================
    - Material Factory is a smart contract responsible for manufacturing raw products, 
    companies will import raw products from the Material Factory to manufacture main products.
    - Material Factory will auto manufacture products every hour.

    - Material product types:
        - Powdered Milk
        - Water
        - Machine Material
        - Kettle
        - Milk Frother
    */

    ICAFProductItems private _productItems;
    ICAFGameEconomy private _gameEconomy;

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _productItems = ICAFProductItems(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );
        _gameEconomy = ICAFGameEconomy(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );
    }

    function manufactureProduct(
        ItemLibrary.ProductItemType _productType
    ) external override onlyRole(SYSTEM_ROLE) {
        ICAFGameEconomy.ManufacturedProduct
            memory manufacturedProduct = _gameEconomy.getManufacturedProduct(
                _productType
            );

        _productItems.createBatch(
            _productType,
            manufacturedProduct.manufacturedPerHour
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {IMaterialFactory} from "../interfaces/IMaterialFactory.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";

contract MaterialFactory is IMaterialFactory {
    // ======================== STATE ========================
    ICAFProductItems private _productItems;
    ICAFContractRegistry private _registry;

    constructor(address _contractRegistry) {
        _registry = ICAFContractRegistry(_contractRegistry);
        _productItems = ICAFProductItems(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );
    }

    function manufactureProduct(
        ItemLibrary.ProductItemType _productType,
        uint256 _manufacturedPerHour
    ) external override returns (uint256) {

        
    }
}

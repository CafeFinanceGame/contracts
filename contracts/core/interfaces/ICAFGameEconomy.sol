// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFGameEconomy {
    // ========================== ACTIONS ==========================

    function updateProductEconomy(
        ItemLibrary.ProductItemType _productType,
        uint256 _energy,
        uint256 _durability,
        uint8 _decayRate,
        uint256 _decayPeriod,
        uint256 _costPrice,
        uint256 _insurancePrice,
        uint256 _freightPrice
    ) external returns (bool);

    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    )
        external
        view
        returns (uint256, uint256, uint8, uint256, uint256, uint256, uint256);
}

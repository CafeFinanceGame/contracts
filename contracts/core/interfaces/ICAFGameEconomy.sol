// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFGameEconomy {
    // ========================== ACTIONS ==========================

    /// @notice Update the economy of a raw material
    /// @param _productType The type of the raw material
    /// @param _energy The energy of the raw material
    /// @param _durability The durability of the raw material
    /// @param _decayRate The decay rate of the raw material
    /// @param _decayPeriod The decay period of the raw material
    /// @param _costPrice The cost price of the raw material
    /// @param _insurancePrice The insurance price of the raw material
    /// @param _freightPrice The freight price of the raw material
    /// @return True if the raw material economy is updated
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

    /// @notice Get the economy of product
    /// @param _productType The type of the product
    /// @return The energy of the product
    /// @return The durability of the product
    /// @return The decay rate of the product
    /// @return The decay period of the product
    /// @return The cost price of the product
    /// @return The insurance price of the product
    /// @return The freight price of the product
    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    )
        external
        view
        returns (uint256, uint256, uint8, uint256, uint256, uint256, uint256);
}

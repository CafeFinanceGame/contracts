// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFManufacturableItems {
    /*
    ============================ 🌍 GAME STORY: MANUFACTORY ============================

    ================================== 🛠 Formula ======================================
    - The manufactory is the place where raw materials are processed into products.
    
    🏢 Coffee Company
    - Black Coffee = Coffee Bean + Water + Kettle
    - Milk Coffee = Black Coffee + Milk

    🌱 Material Company
    - Milk = Powdered Milk + Water + Kettle

    🏭 Machine Company
    - Kettle = Machine Material + Water
    - Milk Frother = Machine Material + Milk
    */

    // ========================== ACTIONS ==========================

    /// @notice Manufacture product
    /// @param _productType The type of the product
    /// @param _componentIds The component ids of the product
    function manufacture(
        ItemLibrary.ProductItemType _productType,
        uint256[] memory _componentIds
    ) external returns (uint256);

    /// @notice Calculate energy of the product
    /// @param _componentIds The component ids of the product
    /// @return The energy of the product
    function calculateEnergy(
        uint256[] memory _componentIds
    ) external returns (uint256);

    /// @notice Calculate durability of the product
    /// @param _componentIds The component ids of the product
    /// @return The durability of the product
    function calculateDurability(
        uint256[] memory _componentIds
    ) external returns (uint256);
}

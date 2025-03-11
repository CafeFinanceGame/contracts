// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFMaterialFactory {
    // ========================= ACTIONS =========================

    /// @notice Auto manufacture product, game center will call this function to manufacture product
    /// @param _productType The type of the product
    function produceProducts(
        ItemLibrary.ProductItemType _productType,
        uint256 _rateProducedPerHour // The rate produced per hour
    ) external;

    /// @notice Auto manufacture product, game center will call this function to manufacture product
    function autoProduceProducts() external;

    // ========================= EVENTS =========================
    event ProductsProduced(
        ItemLibrary.ProductItemType _productType,
        uint256 _rateProducedPerHour
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface IMaterialFactory {
    /// @notice Auto manufacture product, game center will call this function to manufacture product
    /// @dev Only game center can call this function, use Chainlink Automation to call this function
    /// @param _productType The type of the product
    /// @param _manufacturedPerHour The manufactured product per hour
    function manufactureProduct(
        ItemLibrary.ProductItemType _productType,
        uint256 _manufacturedPerHour
    ) external returns (uint256);
}

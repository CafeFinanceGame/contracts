// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface IMaterialFactory {
    /// @notice Auto manufacture product, game center will call this function to manufacture product
    /// @dev Only game center can call this function, use Chainlink Automation to call this function
    /// @param _productType The type of the product
    function manufactureProduct(
        ItemLibrary.ProductItemType _productType
    ) external;
}

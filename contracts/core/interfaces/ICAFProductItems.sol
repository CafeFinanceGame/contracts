// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFProductItems {
    struct ProductItem {
        ItemLibrary.ProductItemType productType;
        uint256 price;
        uint256 energy; // Energy of the item, only for consumable products
        uint256 durability; // Durability of the item, only for machine products
        uint8 decayRate;
        uint256 decayPeriod;
        uint256 lastDecayTime;
    }

    struct ProductItemInfo {
        ItemLibrary.ProductItemType productType;
        uint8 energy;
        uint8 durability;
        uint8 decayRate;
        uint256 decayPeriod;
    }

    struct RawMaterialProductInfo {
        ItemLibrary.ProductItemType productType;
        uint256 costPrice;
        uint256 insurancePrice;
        uint256 freightPrice;
    }

    // ========================== ACTIONS ==========================
    /// @notice Create a new item
    /// @param _companyId The id of the company
    /// @param _type The type of the item
    /// @return The id of the item
    function create(
        uint256 _companyId,
        ItemLibrary.ProductItemType _type
    ) external returns (uint256);

    /// @notice Create a batch of items,
    /// @dev Function support game manufacturer to create a batch of items
    /// @param _type The type of the item
    /// @param _amount The amount of the item
    /// @return The ids of the items
    function createBatch(
        ItemLibrary.ProductItemType _type,
        uint256 _amount
    ) external returns (uint256[] memory);

    /// @notice Get the info of the item
    /// @param _id The id of the item
    /// @return The info of the item
    function get(uint256 _id) external view returns (ProductItem memory);

    /// @notice Update the item
    /// @param _itemId The id of the item
    /// @param _price The price of the item
    /// @param _energy The energy of the item
    /// @param _durability The durability of the item
    /// @param _decayPeriod The decay period of the item
    /// @param _decayRate The decay rate of the item
    function updateProductItem(
        uint256 _itemId,
        uint256 _price,
        uint256 _energy,
        uint256 _durability,
        uint256 _decayPeriod,
        uint8 _decayRate
    ) external;

    // ========================== EVENTS ==========================
    event ProductItemCreated(
        uint256 indexed itemId,
        uint256 indexed companyId,
        uint256 indexed itemType,
        string uri
    );
}

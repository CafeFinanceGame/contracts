// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFProductItems {
    struct ProductItem {
        ItemLibrary.ProductItemType productType;
        uint256 price;
        uint8 energy; // Energy of the item, only for consumable products
        uint8 durability; // Durability of the item, only for machine products
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
    /// @param _uri The uri of the item, include the metadata of the item
    /// @return The id of the item
    function create(
        uint256 _companyId,
        ItemLibrary.ProductItemType _type,
        string calldata _uri
    ) external returns (uint256);

    /// @notice Get the info of the item
    /// @param _id The id of the item
    /// @return The info of the item
    function get(uint256 _id) external view returns (ProductItem memory);

    // ========================== EVENTS ==========================
    event ProductItemCreated(
        uint256 indexed itemId,
        uint256 indexed companyId,
        uint256 indexed itemType,
        string uri
    );
}

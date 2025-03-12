// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {ICAFConsumableItems} from "./ICAFConsumableItems.sol";
import {ICAFManufacturableItems} from "./ICAFManufacturableItems.sol";
import {ICAFDecayableItems} from "./ICAFDecayableItems.sol";

interface ICAFProductItems is
    ICAFDecayableItems,
    ICAFConsumableItems,
    ICAFManufacturableItems
{
    // ========================== TYPES ============================

    struct ProductItem {
        ItemLibrary.ProductItemType productType;
        uint8 energy; // Energy of the item, only for consumable products
        uint8 durability; // Durability of the item, only for machine products
        uint256 decayRatePerQuarterDay; // Decay rate per hour of the item (in amount)
        uint256 mfgTime; // Manufactured time of the item
        uint256 expTime; // Expiration time of the item
        uint256 lastDecayTime; // Last decayed time of the item
    }

    struct ProductItemInfo {
        ItemLibrary.ProductItemType productType;
        uint8 energy;
        uint8 durability;
        uint8 decayRate;
        uint256 decayPeriod;
    }

    struct RawMaterialProductItemInfo {
        ItemLibrary.ProductItemType productType;
        uint256 costPrice;
    }

    struct ProductRecipe {
        ItemLibrary.ProductItemType output;
        ItemLibrary.ProductItemType[] inputs;
    }

    // ========================== ACTIONS ==========================

    /// @notice Create a new product item
    /// @param _companyId The id of the company
    /// @param _productType The type of the product
    function createProductItem(
        uint256 _companyId,
        ItemLibrary.ProductItemType _productType
    ) external;

    /// @notice Get the product item
    /// @param _itemId The id of the item
    /// @return The product item
    function getProductItem(
        uint256 _itemId
    ) external view returns (ProductItem memory);

    /// @notice Get the product item info
    /// @param _owner The owner of the product
    /// @return The product item info
    function getAllProductItemByOwner(
        address _owner
    ) external view returns (uint256[] memory);

    /// @notice Get all product ids
    /// @return All product ids
    function getAllProductItemIds() external view returns (uint256[] memory);

    /// @notice Get the product item info
    /// @param _itemId The id of the item
    /// @param _itemId The id of the item
    /// @return The product item info
    function hasProductItem(
        address _owner,
        uint256 _itemId
    ) external view returns (bool);

    // ========================== EVENTS ==========================
    event ProductItemCreated(uint256 indexed itemId, uint256 indexed companyId);
}

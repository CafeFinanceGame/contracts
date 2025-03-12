// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFGameEconomy {
    // ========================== TYPES ==========================

    struct ProductEconomy {
        uint8 energy;
        uint8 durability;
        uint8 decayRatePerQuarterDay;
        uint256 costPrice;
    }

    enum CompanyAcitivityEnergyFeeType {
        MANUFACTURE,
        BUY,
        RESELL,
        LIST,
        UNLIST,
        UPDATE
    }

    struct ActivityEnergyFee {
        CompanyAcitivityEnergyFeeType activityType;
        uint8 fee;
    }

    struct ManufacturedProduct {
        uint256 manufacturedPerHour;
    }

    // ========================== ACTIONS ==========================

    /// @notice Get the current price basis from the material used to manufacture the product
    /// @param _productType The type of the product
    /// @return The current price basis
    function getCurrentPrice(
        ItemLibrary.ProductItemType _productType
    ) external view returns (uint256);

    /// @notice Update all prices, this function will be called by the game center
    function updateAllPrices() external;

    /// @notice Update the economy of a raw material
    /// @param _productType The type of the raw material
    /// @param _energy The energy of the raw material
    /// @param _durability The durability of the raw material
    /// @param _decayRatePerHour The decay rate of the raw material per hour
    /// @param _costPrice The cost price of the raw material
    /// @return True if the raw material economy is updated
    function updateProductEconomy(
        ItemLibrary.ProductItemType _productType,
        uint256 _energy,
        uint256 _durability,
        uint8 _decayRatePerHour,
        uint256 _costPrice
    ) external returns (bool);

    /// @notice Get the economy of product
    /// @param _productType The type of the product
    /// @return The economy of the product
    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    ) external view returns (ProductEconomy memory);

    /// @notice Update the manufactured product
    /// @param _productType The type of the manufactured product
    /// @param _manufacturedPerHour The manufactured product per hour
    /// @return True if the manufactured product is updated
    function updateManufacturedProduct(
        ItemLibrary.ProductItemType _productType,
        uint256 _manufacturedPerHour
    ) external returns (bool);

    /// @notice Get the manufactured product
    /// @param _productType The type of the manufactured product
    function getManufacturedProduct(
        ItemLibrary.ProductItemType _productType
    ) external view returns (ManufacturedProduct memory);

    /// @notice Update the activity fee
    /// @param _activityType The type of the activity
    /// @param _fee The fee of the activity
    /// @return True if the activity fee is updated
    function updateActivityFee(
        CompanyAcitivityEnergyFeeType _activityType,
        uint256 _fee
    ) external returns (bool);

    /// @notice Get the activity fee
    /// @param _activityType The type of the activity
    function getActivityFee(
        CompanyAcitivityEnergyFeeType _activityType
    ) external view returns (ActivityEnergyFee memory);
}

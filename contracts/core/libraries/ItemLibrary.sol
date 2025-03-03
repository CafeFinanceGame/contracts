// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ItemLibrary {
    struct Item {
        address owner;
        ItemType itemType;
        uint256 amount;
    }

    enum ItemType {
        UTILITY,
        PRODUCT,
        EVENT
    }

    enum ProductItemType {
        // Coffee Company
        COFFEE_BEAN, // Default material product that only coffee company can import
        BLACK_COFFEE, // Formula: Coffee Bean + Water + Kettle
        MILK_COFFEE, // Formula: Black Coffee + Milk
        // Material Company
        POWDERED_MILK, // Default material product that only material company can import
        WATER, // Default material product that only material company can import
        MILK, // Formula: Powdered Milk + Water + Kettle
        // Machine Company
        MACHINE_MATERIAL, // Default material product that only machine company can import
        KETTLE, // Formula: Machine Material + Water
        MILK_FROTHER // Formula: Machine Material + Milk,
    }

    function getUint8Type(ItemType itemType) internal pure returns (uint8) {
        return uint8(itemType);
    }

    function getItemType(uint8 itemType) internal pure returns (ItemType) {
        return ItemType(itemType);
    }
}

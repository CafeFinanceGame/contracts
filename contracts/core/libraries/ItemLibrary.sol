// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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
        BLACK_COFFEE,
        SUGAR_COFFEE,
        ESPRESSO,
        MILK_COFFEE,
        // Material Company
        COFFEE_BEAN,
        MILK,
        SUGAR,
        WATER,
        // Machine Company
        GRINDER,
        KETTLE,
        MOKA_POT,
        MILK_FROTHER
    }

    function getUint8Type(ItemType itemType) internal pure returns (uint8) {
        return uint8(itemType);
    }

    function getItemType(uint8 itemType) internal pure returns (ItemType) {
        return ItemType(itemType);
    }
}

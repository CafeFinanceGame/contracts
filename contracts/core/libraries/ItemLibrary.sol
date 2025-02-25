// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library ItemLibrary {
    struct Item {
        address owner;
        ItemType itemType;
        uint128 amount;
    }

    enum ItemType {
        MATERIAL,
        UTILITY,
        PRODUCT,
        EVENT
    }

    function getUint8Type(ItemType itemType) internal pure returns (uint8) {
        return uint8(itemType);
    }

    function getItemType(uint8 itemType) internal pure returns (ItemType) {
        return ItemType(itemType);
    }
}

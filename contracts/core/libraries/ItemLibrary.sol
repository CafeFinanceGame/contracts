// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library ItemLibrary {
    struct Item {
        address owner;
        ItemType itemType;
        uint256 amount;
    }

    enum ItemType {
        MATERIAL,
        UTILITY,
        PRODUCT,
        EVENT
    }
}

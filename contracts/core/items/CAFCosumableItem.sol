// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./Item.sol";
import "./CAFProductItems.sol";
import "./Companies.sol";

contract ConsumableItem is Item {
    // ========================== STATES ==========================
    /// @notice Available energy of the consumable item
    /// STORY
    /// The energy of the consumable item is the amount of energy that the player can get when they consume the item.
    uint8 public energy;

    // ========================== ACTIONS ==========================
    /// @notice Consume the item
    /// @dev The player can consume the item to get energy.
    function consume(address company) external {
        require(
            Company(company) != Company(address(0)),
            "Item: company not found"
        );
    }
}

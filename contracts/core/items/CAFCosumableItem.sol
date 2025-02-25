// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./CAFItems.sol";
import "./CAFProductItems.sol";
import "./CAFCompanyItems.sol";

abstract contract CAFConsumableItems is CAFItems {
    // ========================== STATES ==========================
    /// @notice Available energy of the consumable item
    /// STORY
    /// The energy of the consumable item is the amount of energy that the player can get when they consume the item.
    uint8 public energy;

    // ========================== ACTIONS ==========================
    /// @notice Consume the item
    /// @dev The player can consume the item to get energy.
    function consume() external {
        require(energy > 0, "CAFConsumableItems: no energy to consume");
        energy = 0;

        emit Consumed(msg.sender, address(this));
    }

    // ========================== EVENTS ==========================
    event Consumed(address indexed player, address indexed item);
}

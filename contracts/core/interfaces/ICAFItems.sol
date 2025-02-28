// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICAFItems {
    // ========================== ACTIONS ==========================

    /// @notice Remove an item
    /// @param _id The id of the item
    /// STORY
    /// Item can be removed by the system, example
    /// - Consumable item is consumed by the player
    /// - Decayable item is decayed
    /// - Event item is expired
    function remove(uint256 _id) external;
}

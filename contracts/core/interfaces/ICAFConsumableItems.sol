// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFConsumableItems {
    // ========================== ACTIONS ==========================
    /// @notice Consume an item
    /// @param _id The id of the item
    function consume(uint256 _id) external;

    // ========================== EVENTS ==========================
    event Consumed(uint256 indexed id);
}

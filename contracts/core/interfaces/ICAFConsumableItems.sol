// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFConsumableItems {
    // ========================== ACTIONS ==========================

    /// @notice Consume an item
    /// @dev The item will be consumed
    /// @param _itemId The item id
    /// @param _amount The amount to consume
    function consume(uint256 _itemId, uint256 _amount) external;

    // ========================== EVENTS ==========================
    
    event Consumed(uint256 indexed id, uint256 amount);
}

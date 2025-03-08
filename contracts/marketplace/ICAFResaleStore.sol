// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFResaleStore {
    // ==================== ACTIONS ====================

    /// @notice Sell an item to CaFi's resale store.
    /// The exchange value depends on the item's experience and quality.
    /// The item will then be listed on the marketplace.
    /// @dev Only item owner can call this function
    /// @param _itemId The id of the item
    function resell(uint256 _itemId) external;

    // ==================== EVENTS ====================
    event ItemResold(
        uint256 indexed _itemId,
        address indexed _owner,
        uint256 _price
    );
}

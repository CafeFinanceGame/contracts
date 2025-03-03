// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFResaleStore {
    // ==================== ACTIONS ====================

    /// @notice Sell an item to CaFi's resale store.
    /// The exchange value depends on the item's experience and quality.
    /// The item will then be listed on the marketplace.
    /// @dev Only item owner can call this function
    /// @param _itemId The id of the item
    function sell(uint256 _itemId) external;

    /// @notice Calculate the resale price of an item.
    /// The resale price depends on the item's experience and quality.
    /// @param _itemId The id of the item
    /// @return The resale price of the item
    function calculateResalePrice(
        uint256 _itemId
    ) external view returns (uint256);

    // ==================== EVENTS ====================
    event ItemResold(
        uint256 indexed _itemId,
        address indexed _owner,
        uint256 _price
    );
}

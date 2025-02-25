// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICAFItems {
    // ========================== ACTIONS ==========================

    /// @notice Create a new item
    /// @param _owner The owner of the item
    /// @param _type The type of the item
    /// @param _uri The uri of the item, include the metadata of the item
    /// @return The id of the item
    function create(
        address _owner,
        uint256 _type,
        string calldata _uri
    ) external returns (uint256);

    /// @notice Remove an item
    /// @param _id The id of the item
    /// STORY
    /// Item can be removed by the system, example
    /// - Consumable item is consumed by the player
    /// - Decayable item is decayed
    /// - Event item is expired
    function remove(uint256 _id) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICAFItems is IERC721 {
    // ========================== ACTIONS ==========================

    /// @notice Create a new item
    /// @param _owner The owner of the item
    /// @param _type The type of the item
    /// @return The id of the item
    function create(address _owner, bytes32 _type) external returns (uint256);

    /// @notice Remove an item
    /// @param _id The id of the item
    /// STORY
    /// Item can be removed by the system, example
    /// - Consumable item is consumed by the player
    /// - Decayable item is decayed
    /// - Event item is expired
    function remove(uint256 _id) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICAFItems {
    // ========================== ACTIONS ==========================

    /// @notice Remove an item
    /// @param _id The id of the item
    function remove(uint256 _id) external;
}

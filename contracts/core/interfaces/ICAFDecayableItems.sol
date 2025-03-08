// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ICAFDecayableItems {
    // ========================== ACTIONS ==========================

    /// @notice Decay the item
    /// @dev The item will lose energy after each decay period.
    /// @param _itemId The item id
    function decay(uint256 _itemId) external returns (uint256);

    // ========================== EVENTS ==========================

    event ItemDecayed(uint256 indexed id, uint256 lastDecayed);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CAFItems.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract CAFDecayableItems is CAFItems {
    struct CAFDecayableItem {
        uint8 decayRate;
        uint256 decayPeriod;
        uint256 lastDecayTime;
    }
    
    // ========================== STATES ==========================

    mapping(uint256 => CAFDecayableItem) public decayableItems;

    constructor(address _contractRegistry) CAFItems(_contractRegistry) {}
    // ========================== ACTIONS ==========================

    /// @notice Decay the item
    /// @dev The item will lose energy after each decay period.
    /// @param _itemId The item id
    function decay(uint256 _itemId) internal virtual returns (uint256);

    // ========================== EVENTS ==========================

    event Decayed(
        address indexed player,
        address indexed item,
        uint8 energy,
        uint8 newEnergy
    );
}

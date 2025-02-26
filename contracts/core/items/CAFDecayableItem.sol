// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    constructor(address _contractRegistry) CAFItems(_contractRegistry) {}
    // ========================== ACTIONS ==========================
    /// @notice Calculate the decay of the item
    /// @dev The item will lose energy after each decay period.
    /// @param _itemId The item id
    /// @return The amount of sth that the item will lose
    function calculateDecay(uint256 _itemId) internal view returns (uint256) {
        CAFDecayableItem storage item = decayableItems[_itemId];
        uint256 timePassed = block.timestamp - item.lastDecayTime;
        uint256 decayCount = timePassed / item.decayPeriod;

        return item.decayRate * decayCount;
    }

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

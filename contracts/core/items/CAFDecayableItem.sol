// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./CAFItems.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract CAFDecayableItem is CAFItems, ERC721Burnable {
    // ========================== STATES ==========================
    /// @notice The decay rate of the item
    /// STORY
    /// - The decay rate of the item is the amount of energy that the item will lose after each decay period.
    uint8 public decayRate;

    /// @notice The decay period of the item
    /// STORY
    /// - The decay period of the item is the amount of time that the item will lose energy after.
    uint256 public decayPeriod;

    /// @notice The last decay time of the item
    /// STORY
    /// - The last decay time of the item is the time that the item was last decayed.
    uint256 public lastDecayTime;

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    constructor(uint8 _decayRate, uint256 _decayPeriod) {
        decayRate = _decayRate;
        decayPeriod = _decayPeriod;
        lastDecayTime = block.timestamp;
    }
    // ========================== ACTIONS ==========================
    /// @notice Calculate the decay of the item
    /// @dev The item will lose energy after each decay period.
    function calculateDecay() public view returns (uint8) {
        uint256 _elapsedTime = block.timestamp - lastDecayTime;
        uint256 _decayCount = _elapsedTime / decayPeriod;

        return uint8(_decayCount * decayRate);
    }

    /// @notice Decay the item
    /// @dev The item will lose energy after each decay period.
    function decay() external virtual;

    // ========================== EVENTS ==========================

    event Decayed(
        address indexed player,
        address indexed item,
        uint8 energy,
        uint8 newEnergy
    );
}

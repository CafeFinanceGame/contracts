// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFGameManger {
    /// @dev Auto trigger all needed functions per hour,
    /// use Chainlink Automation to call this function
    function autoTriggerPerHour() external view;
}

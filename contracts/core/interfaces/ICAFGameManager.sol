// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFGameManger {
    /// @dev Auto trigger all needed functions per hour,
    /// use Chainlink Automation to call this function
    function autoTriggerPerHour() external;

    /// @notice Transfer CAF token
    /// @dev Only game center can call this function
    /// @param _to The address to transfer to
    /// @param _amount The amount to transfer
    function transferToken(address _to, uint256 _amount) external;
}

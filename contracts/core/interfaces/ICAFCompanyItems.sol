// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFCompanyItems {
    // ========================== TYPES ============================

    struct Company {
        address owner;
        ItemLibrary.CompanyType role;
        uint8 energy;
    }

    // ========================== ACTIONS ==========================
    /// @notice Create a new company
    /// @param _owner The owner of the company
    /// @param _role The role of the company
    function createCompanyItem(
        address _owner,
        ItemLibrary.CompanyType _role
    ) external;

    /// @notice Get the company's information
    /// @param _companyId The id of the company
    /// @return The company's information
    function getCompanyItem(
        uint256 _companyId
    ) external view returns (Company memory);

    /// @notice Get all company ids
    /// @return All company ids
    function getAllCompanyItemIds() external view returns (uint256[] memory);

    /// @notice Replenish the company's energy.
    /// @dev Energy is used to perform actions in the game.
    /// @param _companyId The id of the company
    /// @param _itemId Address of the item to replenish energy
    function replenishEnergy(uint256 _companyId, uint256 _itemId) external;

    /// @notice Use energy to do actions that consume energy.
    /// @dev Energy is used to perform actions in the game.
    /// @param _companyId The id of the company
    function useEnergy(uint256 _companyId, uint8 _amount) external;

    // ========================== EVENTS ===========================

    event CompanyItemCreated(uint256 companyId, address owner);
    event EnergyConsumed(uint256 companyId, uint256 amount);
    event EnergyReplenished(uint256 companyId, uint256 amount);
    event EnergyUsed(uint256 companyId, uint256 amount);
}

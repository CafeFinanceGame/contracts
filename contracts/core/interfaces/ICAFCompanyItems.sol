// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/PlayerLibrary.sol";

interface ICAFCompanyItems {
    struct Company {
        address owner;
        PlayerLibrary.PlayerRole role;
        uint8 energy;
        uint256 capitalization;
        uint256 revenue;
        int256 profit;
    }

    // ========================== ACTIONS ==========================
    /// @notice Create a new company.
    /// @dev The company is created with an owner and a role.
    /// @param _owner The address of the company's owner
    /// @param _role The role of the company
    function create(
        address _owner,
        PlayerLibrary.PlayerRole _role
    ) external returns (uint256);

    /// @notice Get company
    /// @dev The role determines the company's abilities and restrictions.
    /// @param _companyId The id of the company
    function get(uint256 _companyId) external view returns (Company memory);

    /// @notice Get company by owner
    /// @param _owner The address of the company's owner
    /// @return The company id
    function getByOwner(address _owner) external view returns (uint256);

    /// @notice Replenish the company's energy.
    /// @dev Energy is used to perform actions in the game.
    /// @param _companyId The id of the company
    /// @param _itemId Address of the item to replenish energy
    function replenishEnergy(uint256 _companyId, uint256 _itemId) external;

    // =========================== STATE ===========================

    /// @notice Role of the company in the game.
    /// @dev The role determines the company's abilities and restrictions.
    /// @param _companyId The id of the company
    function role(
        uint256 _companyId
    ) external view returns (PlayerLibrary.PlayerRole);

    /// @notice The company's energy is used to perform actions in the game.
    /// @dev Energy consumption affects the company's ability to operate.
    /// @param _companyId The id of the company
    function energy(uint256 _companyId) external view returns (uint8);

    /// @notice The total market capitalization of the company.
    /// @dev Represents the total valuation of the company's assets in the game.
    /// @param _companyId The id of the company
    /// @return The market capitalization of the company
    function capitalization(uint256 _companyId) external view returns (uint256);

    /// @notice The total revenue generatzd by the company.
    /// @dev This is the accumulated revenue from business activities.
    /// @param _companyId The id of the company
    /// @return The revenue of the company
    function revenue(uint256 _companyId) external view returns (uint256);

    /// @notice The net profit of the company after deducting expenses.
    /// @dev Profit is calculated as revenue minus costs.
    /// @param _companyId The id of the company
    /// @return The profit of the company
    function profit(uint256 _companyId) external view returns (int256);

    /// @notice Check if the company exists
    /// @param _id The id of the company
    /// @return True if the company exists
    function isCompany(uint256 _id) external view returns (bool);

    /// @notice Check user has company
    /// @param _owner The address of the company's owner
    /// @return True if the user has a company
    function hasCompany(address _owner) external view returns (bool);

    // ========================== EVENTS ===========================

    /// @notice Emitted when the company consumes energy.
    event EnergyConsumed(uint256 companyId, uint8 amount);

    /// @notice Emitted when the company replenishes energy.
    event EnergyReplenished(uint256 companyId, uint8 amount);

    /// @notice Emitted when the market cap of a company changes.
    event MarketCapUpdated(uint256 companyId, uint256 newMarketCap);

    /// @notice Emitted when the revenue of a company increases.
    event RevenueGenerated(uint256 companyId, uint256 amount);

    /// @notice Emitted when the company's profit is updated.
    event ProfitUpdated(uint256 companyId, int256 newProfit);
}

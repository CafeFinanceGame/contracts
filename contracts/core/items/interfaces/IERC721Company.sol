// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../CosumableItem.sol";

interface IERC721Company is IERC721Metadata {
    // ========================== ACTIONS ==========================
    /// @notice Replenish the company's energy.
    /// @dev Energy is used to perform actions in the game.
    /// STORY
    ///   - Players must replenish energy to keep operations running.
    function replenishEnergy(ConsumableItem item) external;

    // =========================== STATE ===========================

    /// @notice The company's energy is used to perform actions in the game.
    /// @dev Energy consumption affects the company's ability to operate.
    /// STORY
    ///   - Each company starts with a maximum of 100 energy.
    ///   - Every day, 10 energy is consumed to maintain production.
    ///   - Players must replenish energy to keep operations running.
    function energy() external view returns (uint8);

    /// @notice The total market capitalization of the company.
    /// @dev Represents the total valuation of the company's assets in the game.
    function capitalization() external view returns (uint256);

    /// @notice The total revenue generated by the company.
    /// @dev This is the accumulated revenue from business activities.
    function revenue() external view returns (uint256);

    /// @notice The net profit of the company after deducting expenses.
    /// @dev Profit is calculated as revenue minus costs.
    function profit() external view returns (int256);

    // ========================== EVENTS ===========================

    /// @notice Emitted when the company consumes energy.
    event EnergyConsumed(address indexed company, uint8 amount);

    /// @notice Emitted when the company replenishes energy.
    event EnergyReplenished(address indexed company, uint8 amount);

    /// @notice Emitted when the market cap of a company changes.
    event MarketCapUpdated(address indexed company, uint256 newMarketCap);

    /// @notice Emitted when the revenue of a company increases.
    event RevenueGenerated(address indexed company, uint256 amount);

    /// @notice Emitted when the company's profit is updated.
    event ProfitUpdated(address indexed company, int256 newProfit);
}

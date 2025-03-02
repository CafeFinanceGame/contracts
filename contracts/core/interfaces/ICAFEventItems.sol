// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICAFEventItems {
    enum EventItemType {
        RawMaterialPriceFluctuations,
        MarketSupplyImbalance
    }

    struct EventItem {
        uint256 startDate;
        uint256 endDate;
        uint256 eventType;
    }

    // ========================== ACTIONS ==========================

    /// @notice Create a new event item
    /// @param _type The type of the event item
    /// @param _startDate The start date of the event item
    /// @param _endDate The end date of the event item
    /// @return The ID of the event item
    function create(
        EventItemType _type,
        uint256 _startDate,
        uint256 _endDate
    ) external returns (uint256);

    /// @notice Get the info of the event item
    /// @param _eventId The ID of the event item
    /// @return The info of the event item
    function get(uint256 _eventId) external view returns (EventItem memory);

    function start(uint256 _eventId) external;

    function end(uint256 _eventId) external;

    // ========================== EVENTS ==========================

    event EventItemCreated(
        uint256 indexed eventId,
        uint256 indexed eventType,
        uint256 startDate,
        uint256 endDate
    );
    event EventItemStarted(uint256 indexed eventId);
    event EventItemEnded(uint256 indexed eventId);
}

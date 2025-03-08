// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";

interface ICAFEventItems {
    // ========================== TYPES ==========================

    struct EventItem {
        ItemLibrary.EventItemType eventType;
        uint256 startDate;
        uint256 endDate;
    }

    // ========================== ACTIONS ==========================

    /// @notice Create an event item
    /// @param _eventType The event type
    /// @param _startDate The start date
    /// @param _endDate The end date
    function createEventItem(
        ItemLibrary.EventItemType _eventType,
        uint256 _startDate,
        uint256 _endDate
    ) external;

    /// @notice Get the event item
    /// @param _eventId The event id
    /// @return The event item
    function getEventItem(
        uint256 _eventId
    ) external view returns (EventItem memory);

    function startEvent(uint256 _eventId) external;

    function endEvent(uint256 _eventId) external;

    // ========================== EVENTS ==========================

    event EventItemCreated(
        uint256 indexed eventId,
        ItemLibrary.EventItemType eventType
    );
    event EventItemStarted(uint256 indexed eventId);
    event EventItemEnded(uint256 indexed eventId);
}

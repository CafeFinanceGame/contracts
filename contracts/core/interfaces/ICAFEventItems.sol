// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICAFEventItems {
    enum EventItemType {
        RawMaterialPriceFluctuations,
        MarketSupplyImbalance
    }

    struct EventItem {
        uint256 startDate;
        uint256 endDate;
        uint256 eventType;
        string metadata;
    }

    // ========================== ACTIONS ==========================

    function create(
        EventItemType _type,
        uint256 _startDate,
        uint256 _endDate,
        string calldata _uri
    ) external returns (uint256);

    function start(uint256 _eventId) external;

    function end(uint256 _eventId) external;

    // ========================== EVENTS ==========================
    event EventItemCreated(uint256 indexed eventId, uint256 indexed eventType, uint256 startDate, uint256 endDate, string uri);
    event EventItemStarted(uint256 indexed eventId);
    event EventItemEnded(uint256 indexed eventId);
}

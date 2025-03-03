// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICAFEventItems} from "../interfaces/ICAFEventItems.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {CAFItems} from "../items/CAFItems.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";

contract CAFEventItems is ICAFEventItems, CAFItems {
    /*
    ============================ 🌍 GAME STORY: EVENTS ============================
    ======================= 📌 All Possible Parameters of a Event =======================
    - 📅📈 Event Date and Time
    - 📌📝 Event Description
    - 📌📝 Event Type

    📊 Global raw material price fluctuations
    - 🚢📦 Transportation of raw materials may be difficult, which can lead to fluctuations in freight rates
    -⚠️🔥 Periods of drought, which can lead to fluctuations in insurance prices
    -🐛📉 Crop diseases degrade raw material quality, driving costs down.
    -⛏️📉 Processing equipment also face increased wear and tear due to lower-grade inputs, leading to higher maintenance costs and inefficiencies in productio

    ⚖️ Market Supply Imbalance
    - 📉📦 Market Oversupply Crisis
    - 🚨⚠️ Severe Product Shortage
    */

    mapping(uint256 => EventItem) public events;

    constructor(
        address _contractRegistry
    )
        ERC1155("https://api.caf.app/items/{id}.json")
        CAFItems(_contractRegistry)
    {}

    function create(
        EventItemType _type,
        uint256 _startDate,
        uint256 _endDate
    ) external override onlyRole(SYSTEM_ROLE) returns (uint256) {
        require(_startDate < _endDate, "CAFEventItems: Invalid date range");

        uint256 _eventId = uint256(
            keccak256(
                abi.encodePacked(_type, _startDate, _endDate, block.timestamp)
            )
        );

        _mint(msg.sender, _eventId, 1, "");

        events[_eventId] = EventItem({
            startDate: _startDate,
            endDate: _endDate,
            eventType: uint256(_type)
        });

        emit EventItemCreated(_eventId, uint256(_type), _startDate, _endDate);

        return _eventId;
    }

    function get(
        uint256 _eventId
    ) external view override returns (EventItem memory) {
        return events[_eventId];
    }

    function remove(uint256 _eventId) external override {
        _burn(msg.sender, _eventId, 1);
    }
    function start(uint256 _eventId) external override onlyRole(SYSTEM_ROLE) {
        require(
            balanceOf(msg.sender, _eventId) > 0,
            "CAFEventItems: Event not owned by player"
        );

        emit EventItemStarted(_eventId);
    }

    function end(uint256 _eventId) external override onlyRole(SYSTEM_ROLE) {
        require(
            balanceOf(msg.sender, _eventId) > 0,
            "CAFEventItems: Event not owned by player"
        );

        _burn(msg.sender, _eventId, 1);

        emit EventItemEnded(_eventId);
    }
}

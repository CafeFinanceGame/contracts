// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {ICAFProductItems} from "./ICAFProductItems.sol";
import {ICAFCompanyItems} from "./ICAFCompanyItems.sol";
import {ICAFEventItems} from "./ICAFEventItems.sol";
import {ICAFMaterialFactory} from "./ICAFMaterialFactory.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICAFItemsManager is
    ICAFProductItems,
    ICAFCompanyItems,
    ICAFEventItems,
    ICAFMaterialFactory,
    IERC1155,
    IERC1155Receiver
{
    // ========================== ACTIONS ============================

    /// @notice Get the next item id
    /// @return The next item id
    function getNextItemId() external view returns (uint256);

    /// @notice Pop not listed item
    /// @return The item id
    function popNotListedItem() external returns (uint256);
}

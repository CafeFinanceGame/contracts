// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ICAFItems.sol";
import {CAFModuleBase} from "../dependency/CAFModuleBase.sol";
import {CAFAccessControl} from "../dependency/CAFAccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract CAFItems is
    ICAFItems,
    CAFModuleBase,
    CAFAccessControl,
    ERC1155
{
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return
            interfaceId == type(ICAFItems).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}
}

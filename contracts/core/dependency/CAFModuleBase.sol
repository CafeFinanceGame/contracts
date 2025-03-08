// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CAFAccessControl} from "./CAFAccessControl.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract CAFModuleBase is CAFAccessControl {
    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControl) returns (bool) {
        return
            interfaceId == type(CAFModuleBase).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

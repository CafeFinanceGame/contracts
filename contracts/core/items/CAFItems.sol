// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/ICAFItems.sol";
import {CAFModuleBase} from "../dependency/CAFModuleBase.sol";
import {CAFAccessControl} from "../dependency/CAFAccessControl.sol";

abstract contract CAFItems is ICAFItems, CAFModuleBase, CAFAccessControl {
    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) CAFModuleBase(_contractRegistry) {}

    // ========================== STATE ==========================
    // ========================== ACTIONS ==========================
    // ========================== EVENTS ==========================
}

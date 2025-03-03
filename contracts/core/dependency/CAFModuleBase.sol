// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ICAFContractRegistry.sol";

abstract contract CAFModuleBase {
    ICAFContractRegistry internal registry;

    constructor(address _contractRegistry) {
        registry = ICAFContractRegistry(_contractRegistry);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../interfaces/ICAFContractRegistry.sol";

abstract contract CAFModuleBase {
    ICAFContractRegistry private contractRegistry;

    constructor(address _contractRegistry) {
        contractRegistry = ICAFContractRegistry(_contractRegistry);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ICAFGameManager} from "../interfaces/ICAFGameManager.sol";
import {CAFToken} from "../../tokenomics/CAFToken.sol";
import {CAFAccessControl} from "./CAFAccessControl.sol";
import {ICAFMaterialFactory} from "../interfaces/ICAFMaterialFactory.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";

contract CAFGameManager is ICAFGameManager, CAFAccessControl {
    CAFToken private _cafToken;
    ICAFMaterialFactory private _materialFactory;

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _cafToken = CAFToken(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry.ContractRegistryType.CAF_TOKEN_CONTRACT
                )
            )
        );

        _grantRole(
            SYSTEM_ROLE,
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MARKETPLACE_CONTRACT
                )
            )
        );
    }

    function transferToken(
        address _to,
        uint256 _amount
    ) external override onlyRole(SYSTEM_ROLE) {
        _cafToken.transfer(_to, _amount);
    }
}

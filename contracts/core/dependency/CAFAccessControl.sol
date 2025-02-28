// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ControlLibrary} from "../libraries/ControlLibrary.sol";
import {CAFModuleBase} from "./CAFModuleBase.sol";

abstract contract CAFAccessControl is AccessControl {
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICAFContractRegistry private contractRegistry;

    constructor(address _contractRegistry) {
        contractRegistry = ICAFContractRegistry(_contractRegistry);

        _grantRole(
            SYSTEM_ROLE,
            contractRegistry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            contractRegistry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MATERIAL_ITEMS_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            contractRegistry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            contractRegistry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MACHINE_ITEMS_CONTRACT
                )
            )
        );

        _grantRole(ADMIN_ROLE, msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ControlLibrary} from "../libraries/ControlLibrary.sol";
import {CAFModuleBase} from "./CAFModuleBase.sol";

abstract contract CAFAccessControl is AccessControl, CAFModuleBase {
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address _contractRegistry) CAFModuleBase(_contractRegistry) {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(SYSTEM_ROLE, ADMIN_ROLE);
    }

    function setUp() external onlyRole(ADMIN_ROLE) {
        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MARKETPLACE_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_MANAGER_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MATERIAL_FACTORY_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            )
        );

        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );

        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_EVENT_ITEMS_CONTRACT
                )
            )
        );

        _grantRole(
            SYSTEM_ROLE,
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry.ContractRegistryType.CAF_POOL_CONTRACT
                )
            )
        );

        _grantRole(SYSTEM_ROLE, address(this));
    }
}

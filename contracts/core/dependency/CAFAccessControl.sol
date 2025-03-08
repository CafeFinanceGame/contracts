// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ControlLibrary} from "../libraries/ControlLibrary.sol";

abstract contract CAFAccessControl is AccessControl {
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICAFContractRegistry internal _registry;

    constructor(address _contractRegistry) {
        _registry = ICAFContractRegistry(_contractRegistry);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(SYSTEM_ROLE, ADMIN_ROLE);
    }

    function setUp() external virtual onlyRole(ADMIN_ROLE) {
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
        _grantRole(
            SYSTEM_ROLE,
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_MANAGER_CONTRACT
                )
            )
        );
        _grantRole(
            SYSTEM_ROLE,
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );

        _grantRole(SYSTEM_ROLE, address(this));
    }
}

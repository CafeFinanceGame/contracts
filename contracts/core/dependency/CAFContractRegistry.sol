// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {CAFAccessControl} from "./CAFAccessControl.sol";

contract CAFContractRegistry is
    Ownable,
    ICAFContractRegistry,
    CAFAccessControl
{
    // ======================== Contracts Type ========================
    // uint256 public constant CAF_MARKETPLACE_CONTRACT =
    //     keccak256("CAF_MARKETPLACE_CONTRACT");
    // uint256 public constant CAF_POOL_CONTRACT =
    //     keccak256("CAF_POOL_CONTRACT");
    // uint256 public constant CAF_MATERIAL_ITEMS_CONTRACT =
    //     keccak256("CAF_MATERIAL_ITEMS_CONTRACT");
    // uint256 public constant CAF_MACHINE_ITEMS_CONTRACT =
    //     keccak256("CAF_MACHINE_ITEMS_CONTRACT");

    // ======================== Storage ========================
    mapping(uint256 => address) private contracts;

    constructor() Ownable(msg.sender) CAFAccessControl(address(this)) {}

    // ======================== Functions ========================
    function getContractAddress(
        uint256 contractType
    ) external view override returns (address) {
        return contracts[contractType];
    }

    function registerContract(
        uint256 contractType,
        address contractAddress
    ) external override {
        require(
            contractAddress != address(0),
            "CAFContractRegistry: contract address is zero"
        );

        require(
            contractType == uint256(ContractRegistryType.CAF_POOL_CONTRACT) ||
                contractType ==
                uint256(ContractRegistryType.CAF_GAME_MANAGER_CONTRACT) ||
                contractType ==
                uint256(ContractRegistryType.CAF_GAME_ECONOMY_CONTRACT) ||
                contractType ==
                uint256(ContractRegistryType.CAF_MATERIAL_ITEMS_CONTRACT) ||
                contractType ==
                uint256(ContractRegistryType.CAF_PRODUCT_ITEMS_CONTRACT) ||
                contractType ==
                uint256(ContractRegistryType.CAF_MACHINE_ITEMS_CONTRACT)
        );

        contracts[contractType] = contractAddress;
    }

    function unregisterContract(uint256 contractType) external override {
        require(
            contracts[contractType] != address(0),
            "CAFContractRegistry: contract address is zero"
        );

        delete contracts[contractType];
    }
}

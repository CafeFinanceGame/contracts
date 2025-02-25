// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CAFContractRegistry is Ownable {
    // ======================== Contracts Type ========================
    bytes32 public constant CAF_MARKETPLACE_CONTRACT =
        keccak256("CAF_MARKETPLACE_CONTRACT");
    bytes32 public constant CAF_POOL_FACTORY_CONTRACT =
        keccak256("CAF_POOL_FACTORY_CONTRACT");
    bytes32 public constant CAF_MATERIAL_ITEMS_FACTORY_CONTRACT =
        keccak256("CAF_MATERIAL_ITEMS_FACTORY_CONTRACT");
    bytes32 public constant CAF_MACHINE_ITEMS_FACTORY_CONTRACT =
        keccak256("CAF_MACHINE_ITEMS_FACTORY_CONTRACT");

    // ======================== Storage ========================
    mapping(bytes32 => address) private contracts;

    constructor() Ownable(msg.sender) {}

    // ======================== Functions ========================
    function getContract(bytes32 _contractName) public view returns (address) {
        return contracts[_contractName];
    }

    function setContract(
        bytes32 _contractName,
        address _contractAddress
    ) public {
        contracts[_contractName] = _contractAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {CAFAccessControl} from "./CAFAccessControl.sol";

contract CAFContractRegistry is
    Ownable,
    ICAFContractRegistry,
    CAFAccessControl
{
    mapping(uint256 => address) private contracts;

    constructor() Ownable(msg.sender) CAFAccessControl(address(this)) {}

    function getContractAddress(
        uint256 contractType
    ) external view override returns (address) {
        return contracts[contractType];
    }

    function registerContract(
        uint256 contractType,
        address contractAddress
    ) external override onlyRole(ADMIN_ROLE) {
        require(
            contractAddress != address(0),
            "CAFContractRegistry: contract address is zero"
        );

        contracts[contractType] = contractAddress;
    }

    function unregisterContract(
        uint256 contractType
    ) external override onlyRole(ADMIN_ROLE) {
        require(
            contracts[contractType] != address(0),
            "CAFContractRegistry: contract address is zero"
        );

        delete contracts[contractType];
    }
}

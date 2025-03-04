// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ICAFToken.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {CAFAccessControl} from "../core/dependency/CAFAccessControl.sol";
import {ICAFContractRegistry} from "../core/interfaces/ICAFContractRegistry.sol";

contract CAFToken is ICAFToken, ERC20, CAFAccessControl {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    constructor(
        address _contractRegistry
    ) ERC20("CaFi", "CAF") CAFAccessControl(_contractRegistry) {
        // 20% of the total supply is minted to the deployer
        // 80% of the total supply is minted to the system
        _mint(msg.sender, (INITIAL_SUPPLY * 20) / 100);
        _mint(
            ICAFContractRegistry(_contractRegistry).getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_MANAGER_CONTRACT
                )
            ),
            (INITIAL_SUPPLY * 80) / 100
        );
    }
    
    function mint(address to, uint256 amount) public override {
        require(
            hasRole(SYSTEM_ROLE, msg.sender) || hasRole(ADMIN_ROLE, msg.sender),
            "CAFToken: must have access to mint"
        );
        _mint(to, amount);
    }

    function burn(uint256 amount) public override {
        require(
            hasRole(SYSTEM_ROLE, msg.sender) || hasRole(ADMIN_ROLE, msg.sender),
            "CAFToken: must have access to burn"
        );
        _burn(msg.sender, amount);
    }
}

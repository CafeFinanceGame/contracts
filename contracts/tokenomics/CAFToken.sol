// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/ICAFToken.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CAFToken is ICAFToken, ERC20, Ownable {
    constructor(
        address initialOwner,
        uint256 initialSupply
    ) Ownable(initialOwner) ERC20("CaFi", "CAF") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

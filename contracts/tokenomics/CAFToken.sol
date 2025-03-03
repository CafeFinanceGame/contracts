// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/ICAFToken.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CAFToken is ICAFToken, ERC20, Ownable {
    uint256 public constant initialSupply = 1000000 * 10**18;
    
    constructor() ERC20("CaFi", "CAF") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

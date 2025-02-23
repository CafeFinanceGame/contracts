// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ICAFToken.sol";

contract CAFToken is ICAFToken {
    constructor(address initialOwner, uint256 initialSupply) Ownable(initialOwner) ERC20("CaFi", "CAF") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
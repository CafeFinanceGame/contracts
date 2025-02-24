// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IItem.sol";

interface IERC1155Product is IItem, IERC1155 {}

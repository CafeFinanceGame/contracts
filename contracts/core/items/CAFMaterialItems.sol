// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ICAFMaterialItems.sol";
import "../interfaces/ICAFContractRegistry.sol";
import "../libraries/ItemLibrary.sol";


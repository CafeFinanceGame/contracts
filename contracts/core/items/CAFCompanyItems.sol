// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../items/interfaces/ICAFCompanyItems.sol";
import "../../core/libraries/PlayerLibrary.sol";

contract CAFCompanyItems is ICAFCompanyItems, ERC721URIStorage {
    struct Company {
        PlayerLibrary.PlayerRole role;
        uint8 energy;
        uint128 capitalization;
        uint128 revenue;
        int256 profit;
    }

    // ========================== STATE ==========================

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC721(_name, _symbol) {
        _setTokenURI(_uri);
    }
    // ========================== ACTIONS ==========================
    // ========================== EVENTS ==========================
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../items/interfaces/ICompanyItem.sol";
import "../../core/libraries/PlayerLibrary.sol";

contract Companies is ICompanyItem, ERC721URIStorage {
    struct Company {
        PlayerLibrary.PlayerRole role;
        uint8 energy;
        uint256 capitalization;
        uint256 revenue;
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

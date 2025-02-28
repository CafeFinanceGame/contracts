// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {CAFItems} from "../items/CAFItems.sol";
import {ICAFCompanyItems} from "../interfaces/ICAFCompanyItems.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";

import "../../core/libraries/PlayerLibrary.sol";
import "../libraries/ControlLibrary.sol";

contract CAFCompanyItems is
    ICAFCompanyItems,
    CAFItems,
    ERC721,
    ERC721URIStorage
{
    struct Company {
        PlayerLibrary.PlayerRole role;
        uint8 energy;
        uint256 capitalization;
        uint256 revenue;
        int256 profit;
    }

    // ========================== STATE ==========================
    uint8 public constant INITIAL_ENERGY = 100;
    uint256 public constant INITIAL_CAPITALIZATION = 0;
    uint256 public constant INITIAL_REVENUE = 0;
    int256 public constant INITIAL_PROFIT = 0;

    uint256 private _nextTokenId = 1;
    mapping(uint256 => Company) public companies;

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721URIStorage) returns (bool) {
        return
            interfaceId == type(ICAFCompanyItems).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    constructor(
        address _contractRegistry
    ) ERC721("Company", "CAF_COMP") CAFItems(_contractRegistry) {}

    // ========================== ACTIONS ==========================
    function create(
        address _owner,
        uint256 _type,
        string memory _uri
    ) external override returns (uint256) {
        uint256 _companyId = _nextTokenId++;

        _mint(_owner, _companyId);
        _setTokenURI(_companyId, _uri);

        companies[_companyId] = Company({
            role: PlayerLibrary.PlayerRole(_type),
            energy: INITIAL_ENERGY,
            capitalization: INITIAL_CAPITALIZATION,
            revenue: INITIAL_REVENUE,
            profit: INITIAL_PROFIT
        });

        return _companyId;
    }

    function remove(
        uint256 _companyId
    ) external override onlyExist(_companyId) {
        _burn(_companyId);
        delete companies[_companyId];
    }

    function replenishEnergy(
        uint256 _companyId,
        CAFConsumableItems _item
    ) external override onlyExist(_companyId) {
        uint8 _energy = _item.energy();
        _item.consume();
        companies[_companyId].energy += _energy;

        emit EnergyReplenished(_companyId, _energy);
    }

    function role(
        uint256 _companyId
    )
        external
        view
        override
        onlyExist(_companyId)
        returns (PlayerLibrary.PlayerRole)
    {
        return companies[_companyId].role;
    }

    function energy(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint8) {
        return companies[_companyId].energy;
    }

    function capitalization(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint256) {
        return companies[_companyId].capitalization;
    }

    function revenue(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint256) {
        return companies[_companyId].revenue;
    }

    function profit(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (int256) {
        return companies[_companyId].profit;
    }

    function isCompany(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (bool) {
        return _companyId > 0 && _companyId < _nextTokenId;
    }

    modifier onlyExist(uint256 _companyId) {
        require(
            _companyId > 0 && _companyId < _nextTokenId,
            "CAF: Company does not exist"
        );
        _;
    }
    // ========================== EVENTS ==========================
}

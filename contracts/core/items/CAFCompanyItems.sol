// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {CAFItems} from "../items/CAFItems.sol";
import {ICAFCompanyItems} from "../interfaces/ICAFCompanyItems.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";
import {PlayerLibrary} from "../../core/libraries/PlayerLibrary.sol";
import {ControlLibrary} from "../libraries/ControlLibrary.sol";

contract CAFCompanyItems is ICAFCompanyItems, CAFItems {
    // ========================== STATE ==========================
    uint8 public constant INITIAL_ENERGY = 100;
    uint256 public constant INITIAL_CAPITALIZATION = 0;
    uint256 public constant INITIAL_REVENUE = 0;
    int256 public constant INITIAL_PROFIT = 0;

    mapping(uint256 => Company) private _companies;

    constructor(
        address _contractRegistry
    ) CAFItems(_contractRegistry) ERC1155("") {}

    // ========================== ACTIONS ==========================
    function create(
        address _owner,
        PlayerLibrary.PlayerRole _type
    ) external override returns (uint256) {
        uint256 _companyId = uint256(
            keccak256(abi.encodePacked(_owner, _type))
        );
        _mint(_owner, _companyId, 1, "");

        _companies[_companyId] = Company({
            owner: _owner,
            role: _type,
            energy: INITIAL_ENERGY,
            capitalization: INITIAL_CAPITALIZATION,
            revenue: INITIAL_REVENUE,
            profit: INITIAL_PROFIT
        });

        return _companyId;
    }

    function get(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (Company memory) {
        return _companies[_companyId];
    }

    function remove(
        uint256 _companyId
    ) external override onlyExist(_companyId) {
        // _burn(_companyId);
        // delete _companies[_companyId];
    }

    function replenishEnergy(
        uint256 _companyId,
        uint256 _itemId
    ) external override onlyExist(_companyId) {}

    function role(
        uint256 _companyId
    )
        external
        view
        override
        onlyExist(_companyId)
        returns (PlayerLibrary.PlayerRole)
    {
        return _companies[_companyId].role;
    }

    function energy(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint8) {
        return _companies[_companyId].energy;
    }

    function capitalization(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint256) {
        return _companies[_companyId].capitalization;
    }

    function revenue(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (uint256) {
        return _companies[_companyId].revenue;
    }

    function profit(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (int256) {
        return _companies[_companyId].profit;
    }

    function isCompany(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (bool) {
        return _companies[_companyId].owner != address(0);
    }

    modifier onlyExist(uint256 _companyId) {
        require(
            _companyId > 0 && _companies[_companyId].owner != address(0),
            "CAF: Company does not exist"
        );
        _;
    }
}

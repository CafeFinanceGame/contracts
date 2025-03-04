// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {CAFItems} from "../items/CAFItems.sol";
import {ICAFCompanyItems} from "../interfaces/ICAFCompanyItems.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {PlayerLibrary} from "../../core/libraries/PlayerLibrary.sol";
import {ControlLibrary} from "../libraries/ControlLibrary.sol";

contract CAFCompanyItems is ICAFCompanyItems, CAFItems {
    uint8 public constant INITIAL_ENERGY = 100;
    uint256 private _nextCompanyId = 1;

    mapping(uint256 => Company) private _companies;
    mapping(address => uint256) private _ownerToCompany;
    ICAFProductItems private _productItems;

    constructor(
        address _contractRegistry
    )
        CAFItems(_contractRegistry)
        ERC1155("https://cafigame.vercel.app/api/items/company/{id}.json")
    {}

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _productItems = ICAFProductItems(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );
    }

    function create(
        address _owner,
        PlayerLibrary.PlayerRole _type
    ) external override returns (uint256) {
        require(
            _owner != address(0),
            "CAF: Company owner cannot be the zero address"
        );
        require(
            _ownerToCompany[_owner] == 0,
            "CAF: Company already exists for this owner"
        );

        uint256 _companyId = _nextCompanyId++;
        _mint(_owner, _companyId, 1, "");

        _companies[_companyId] = Company({
            owner: _owner,
            role: _type,
            energy: INITIAL_ENERGY
        });

        _ownerToCompany[_owner] = _companyId;

        return _companyId;
    }

    function get(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (Company memory) {
        return _companies[_companyId];
    }

    function getByOwner(
        address _owner
    ) external view override returns (uint256) {
        return _ownerToCompany[_owner];
    }

    function remove(
        uint256 _companyId
    ) external override onlyExist(_companyId) onlyOwner(_companyId) {
        require(
            _companies[_companyId].owner == msg.sender,
            "CAF: Company does not belong to sender"
        );

        _burn(msg.sender, _companyId, 1);

        delete _companies[_companyId];
        delete _ownerToCompany[msg.sender];
    }

    function replenishEnergy(
        uint256 _companyId,
        uint256 _itemId
    ) external override onlyExist(_companyId) onlyOwner(_companyId) {
        require(
            _companies[_companyId].energy < 100,
            "CAF: Energy is already full"
        );

        uint256 _neededEnergy = 100 - _companies[_companyId].energy;

        _productItems.consume(_itemId, _neededEnergy);

        emit EnergyReplenished(_companyId, _neededEnergy);
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
        return _companies[_companyId].role;
    }

    function useEnergy(uint256 _companyId, uint8 _amount) external override {
        require(
            hasRole(SYSTEM_ROLE, msg.sender) ||
                _companies[_companyId].owner == msg.sender,
            "CAF: Sender is not the owner"
        );

        require(
            _companies[_companyId].energy >= _amount,
            "CAF: Insufficient energy"
        );

        _companies[_companyId].energy -= _amount;

        emit EnergyUsed(_companyId, _amount);
    }

    function energy(uint256 _companyId) external view override returns (uint8) {
        return _companies[_companyId].energy;
    }

    function isCompany(
        uint256 _companyId
    ) external view override onlyExist(_companyId) returns (bool) {
        return _companies[_companyId].owner != address(0);
    }

    function hasCompany(address _owner) external view override returns (bool) {
        return _ownerToCompany[_owner] != 0;
    }

    modifier onlyExist(uint256 _companyId) {
        require(
            _companyId > 0 && _companies[_companyId].owner != address(0),
            "CAF: Company does not exist"
        );
        _;
    }

    modifier onlyOwner(uint256 _companyId) {
        require(
            _companies[_companyId].owner == msg.sender,
            "CAF: Company does not belong to sender"
        );
        _;
    }
}

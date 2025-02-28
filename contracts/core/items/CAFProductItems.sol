// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import "../interfaces/ICAFProductItems.sol";
import "../interfaces/ICAFContractRegistry.sol";
import "../libraries/ItemLibrary.sol";
import "../items/CAFCompanyItems.sol";
import {CAFDecayableItems} from "../items/CAFDecayableItems.sol";

contract CAFProductItems is
    ICAFProductItems,
    ERC1155,
    ERC1155Burnable,
    CAFDecayableItems
{
    /*
    ============================ 🌍 GAME STORY: PRODUCTS ============================
    - Products are the items that are produced by the player using the machines.
    - Products are made from materials and machines.
    - Each company which produces products has to import materials or machines.
    */

    // ============================== STATES =========================================
    ICAFGameEconomy private _gameEconomy;

    address private immutable _companyItemsAddress;
    mapping(uint256 => ProductItem) public productItems;
    mapping(uint256 => ProductItemInfo) private _newProductInfo;

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, CAFDecayableItems) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    constructor(
        address _contractRegistry
    )
        CAFDecayableItem(_contractRegistry)
        ERC1155("https://game.example/api/item/{id}.json")
    {
        _companyItemsAddress = ICAFContractRegistry(_contractRegistry)
            .getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            );

        _gameEconomy = CAFGameEconomy(
            ICAFContractRegistry(_contractRegistry).getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );
    }
    // ============================== MODIFIER =========================================

    modifier isNotExpired(uint256 _itemId) {
        require(
            productItems[_itemId].lastDecayTime +
                productItems[_itemId].decayPeriod >
                block.timestamp,
            "ProductItems: item is expired"
        );
        _;
    }

    modifier isExpired(uint256 _itemId) {
        require(
            productItems[_itemId].lastDecayTime +
                productItems[_itemId].decayPeriod <=
                block.timestamp,
            "ProductItems: item is not expired"
        );
        _;
    }

    // ============================== ACTIONS =========================================

    function create(
        uint256 _companyId,
        ProductItemType _type,
        string memory _uri
    ) external override onlyRole(SYSTEM_ROLE) returns (uint256) {
        require(
            _type == ProductItemType.BLACK_COFFEE ||
                _type == ProductItemType.SUGAR_COFFEE ||
                _type == ProductItemType.ESPRESSO ||
                _type == ProductItemType.MILK_COFFEE ||
                _type == ProductItemType.COFFEE_BEAN ||
                _type == ProductItemType.MILK ||
                _type == ProductItemType.SUGAR ||
                _type == ProductItemType.WATER ||
                _type == ProductItemType.GRINDER ||
                _type == ProductItemType.KETTLE ||
                _type == ProductItemType.MOKA_POT ||
                _type == ProductItemType.MILK_FROTHER,
            "ProductItems: invalid type"
        );

        uint256 id = uint256(
            keccak256(abi.encodePacked(_type, _uri, block.timestamp))
        );

        ProductItem memory item = productItems[id];
        item.productType = ProductItemType(_type);
        item.energy = _gameEconomy.getProductEconomy(_type).energy;
        item.durability = _gameEconomy.getProductEconomy(_type).durability;
        item.decayRate = _gameEconomy.getProductEconomy(_type).decayRate;
        item.decayPeriod = _gameEconomy.getProductEconomy(_type).decayPeriod;
        item.lastDecayTime = block.timestamp;

        productItems[id] = item;

        _mint(msg.sender, id, 1, "");

        return id;
    }

    function remove(uint256 _id) external override {
        _burn(msg.sender, _id, 1);
    }

    function decay(
        uint256 _itemId
    ) internal override isExpired(_itemId) returns (uint256) {
        ProductItem storage item = productItems[_itemId];
        uint256 timePassed = block.timestamp - item.lastDecayTime;
        uint256 decayCount = timePassed / item.decayPeriod;

        uint256 decayAmount = item.decayRate * decayCount;
        if (item.energy > 0) {
            item.energy -= uint8(decayAmount);
        } else {
            item.durability -= uint8(decayAmount);
        }

        item.lastDecayTime += decayCount * item.decayPeriod;

        return decayAmount;
    }
}

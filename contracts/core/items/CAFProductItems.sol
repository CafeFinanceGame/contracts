// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import {ICAFProductItems} from "../interfaces/ICAFProductItems.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ICAFConsumableItems} from "../interfaces/ICAFConsumableItems.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {ICAFCompanyItems} from "../interfaces/ICAFCompanyItems.sol";
import {CAFDecayableItems} from "../items/CAFDecayableItems.sol";
import {CAFItems} from "../items/CAFItems.sol";

contract CAFProductItems is
    ICAFProductItems,
    ICAFConsumableItems,
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
    ) public view override(ERC1155, CAFItems) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    constructor(
        address _contractRegistry
    ) ERC1155("") CAFDecayableItems(_contractRegistry) {
        _companyItemsAddress = ICAFContractRegistry(_contractRegistry)
            .getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            );

        _gameEconomy = ICAFGameEconomy(
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
        ItemLibrary.ProductItemType _type,
        string memory _uri
    ) external override onlyRole(SYSTEM_ROLE) returns (uint256) {
        require(
            ICAFCompanyItems(_companyItemsAddress).get(_companyId).owner !=
                address(0),
            "ProductItems: company does not exist"
        );

        require(
            _type == ItemLibrary.ProductItemType.BLACK_COFFEE ||
                _type == ItemLibrary.ProductItemType.SUGAR_COFFEE ||
                _type == ItemLibrary.ProductItemType.ESPRESSO ||
                _type == ItemLibrary.ProductItemType.MILK_COFFEE ||
                _type == ItemLibrary.ProductItemType.COFFEE_BEAN ||
                _type == ItemLibrary.ProductItemType.MILK ||
                _type == ItemLibrary.ProductItemType.SUGAR ||
                _type == ItemLibrary.ProductItemType.WATER ||
                _type == ItemLibrary.ProductItemType.GRINDER ||
                _type == ItemLibrary.ProductItemType.KETTLE ||
                _type == ItemLibrary.ProductItemType.MOKA_POT ||
                _type == ItemLibrary.ProductItemType.MILK_FROTHER,
            "ProductItems: invalid type"
        );

        uint256 id = uint256(
            keccak256(abi.encodePacked(_type, _uri, block.timestamp))
        );

        ProductItem memory item = productItems[id];
        item.lastDecayTime = block.timestamp;

        productItems[id] = item;

        _mint(msg.sender, id, 1, "");

        return id;
    }

    function get(
        uint256 _id
    ) external view override returns (ProductItem memory) {
        return productItems[_id];
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

    function consume(uint256 _itemId) external override isNotExpired(_itemId) {
        require(
            balanceOf(msg.sender, _itemId) >= 1,
            "ProductItems: insufficient balance"
        );

        productItems[_itemId].energy = 0;

        emit Consumed(_itemId);
    }
}

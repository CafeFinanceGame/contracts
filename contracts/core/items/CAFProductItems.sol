// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ICAFProductItems.sol";
import "../dependency/ICAFContractRegistry.sol";
import "../libraries/ItemLibrary.sol";
import "../items/CAFCompanyItems.sol";
import {CAFDecayableItems} from "../items/CAFDecayableItem.sol";

contract CAFProductItems is
    ICAFProducts,
    ERC1155,
    ERC1155Burnable,
    CAFDecayableItems
{
    // ======================== 🌍 GAME STORY: PRODUCTS ========================
    // Decay information of the product items
    // Coffee Company
    // - Black Coffee: 1 energy per 2 hour
    // - Sugar Coffee: 4 energy per 1 hour
    // - Espresso: 3 energy per 1 hour
    // - Milk Coffee: 6 energy per 1 hours
    // Material Company
    // - Coffee Bean: 1 energy per 3 hours
    // - Milk: 3 energy per 1 hour
    // - Sugar: 4 energy per 1 hours
    // - Water: 1 energy per 6 hours
    // Machine Company
    // - Grinder: 3 durability per 1 hours
    // - Kettle: 2 durability per 1 hours
    // - Moka Pot: 1 durability per 1 hours
    // - Milk Frother: 4 durability per 1 hours
    // ====================================================================================

    enum ProductItemType {
        // Coffee Company
        BLACK_COFFEE,
        SUGAR_COFFEE,
        ESPRESSO,
        MILK_COFFEE,
        // Material Company
        COFFEE_BEAN,
        MILK,
        SUGAR,
        WATER,
        // Machine Company
        GRINDER,
        KETTLE,
        MOKA_POT,
        MILK_FROTHER
    }

    struct ProductItem {
        uint256 price;
        uint8 energy; // Energy of the item, only for consumable products
        uint8 durability; // Durability of the item, only for machine products
        uint8 decayRate;
        uint256 decayPeriod;
        uint256 lastDecayTime;
    }

    struct ProductItemInfo {
        uint8 energy;
        uint8 durability;
        uint8 decayRate;
        uint256 decayPeriod;
    }

    // ============================== STATES =========================================
    uint8 private constant BLACK_COFFEE_DECAY_RATE = 1;
    uint256 private constant BLACK_COFFEE_DECAY_PERIOD = 2 hours;

    uint8 private constant SUGAR_COFFEE_DECAY_RATE = 4;
    uint256 private constant SUGAR_COFFEE_DECAY_PERIOD = 1 hours;

    uint8 private constant ESPRESSO_DECAY_RATE = 3;
    uint256 private constant ESPRESSO_DECAY_PERIOD = 1 hours;

    uint8 private constant MILK_COFFEE_DECAY_RATE = 6;
    uint256 private constant MILK_COFFEE_DECAY_PERIOD = 1 hours;

    uint8 private constant COFFEE_BEAN_DECAY_RATE = 1;
    uint256 private constant COFFEE_BEAN_DECAY_PERIOD = 3 hours;

    uint8 private constant MILK_DECAY_RATE = 3;
    uint256 private constant MILK_DECAY_PERIOD = 1 hours;

    uint8 private constant SUGAR_DECAY_RATE = 4;
    uint256 private constant SUGAR_DECAY_PERIOD = 1 hours;

    uint8 private constant WATER_DECAY_RATE = 1;
    uint256 private constant WATER_DECAY_PERIOD = 6 hours;

    uint8 private constant GRINDER_DECAY_RATE = 3;
    uint256 private constant GRINDER_DECAY_PERIOD = 1 hours;

    uint8 private constant KETTLE_DECAY_RATE = 2;
    uint256 private constant KETTLE_DECAY_PERIOD = 1 hours;

    uint8 private constant MOKA_POT_DECAY_RATE = 1;
    uint256 private constant MOKA_POT_DECAY_PERIOD = 1 hours;

    uint8 private constant MILK_FROTHER_DECAY_RATE = 4;
    uint256 private constant MILK_FROTHER_DECAY_PERIOD = 1 hours;

    uint8 private DEFAULT_ENERGY = 100;
    uint8 private DEFAULT_DURABILITY = 100;

    uint256 private _nextTokenId = 1;
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
        CAFDecayableItems(_contractRegistry)
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

    function _initialize() private {
        _newProductInfo[
            uint256(ProductItemType.BLACK_COFFEE)
        ] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: BLACK_COFFEE_DECAY_RATE,
            decayPeriod: BLACK_COFFEE_DECAY_PERIOD
        });

        _newProductInfo[
            uint256(ProductItemType.SUGAR_COFFEE)
        ] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: SUGAR_COFFEE_DECAY_RATE,
            decayPeriod: SUGAR_COFFEE_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.ESPRESSO)] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: ESPRESSO_DECAY_RATE,
            decayPeriod: ESPRESSO_DECAY_PERIOD
        });

        _newProductInfo[
            uint256(ProductItemType.MILK_COFFEE)
        ] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: MILK_COFFEE_DECAY_RATE,
            decayPeriod: MILK_COFFEE_DECAY_PERIOD
        });

        _newProductInfo[
            uint256(ProductItemType.COFFEE_BEAN)
        ] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: COFFEE_BEAN_DECAY_RATE,
            decayPeriod: COFFEE_BEAN_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.MILK)] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: MILK_DECAY_RATE,
            decayPeriod: MILK_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.SUGAR)] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: SUGAR_DECAY_RATE,
            decayPeriod: SUGAR_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.WATER)] = ProductItemInfo({
            energy: DEFAULT_ENERGY,
            durability: DEFAULT_DURABILITY,
            decayRate: WATER_DECAY_RATE,
            decayPeriod: WATER_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.GRINDER)] = ProductItemInfo({
            energy: 0,
            durability: DEFAULT_DURABILITY,
            decayRate: GRINDER_DECAY_RATE,
            decayPeriod: GRINDER_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.KETTLE)] = ProductItemInfo({
            energy: 0,
            durability: DEFAULT_DURABILITY,
            decayRate: KETTLE_DECAY_RATE,
            decayPeriod: KETTLE_DECAY_PERIOD
        });

        _newProductInfo[uint256(ProductItemType.MOKA_POT)] = ProductItemInfo({
            energy: 0,
            durability: DEFAULT_DURABILITY,
            decayRate: MOKA_POT_DECAY_RATE,
            decayPeriod: MOKA_POT_DECAY_PERIOD
        });

        _newProductInfo[
            uint256(ProductItemType.MILK_FROTHER)
        ] = ProductItemInfo({
            energy: 0,
            durability: DEFAULT_DURABILITY,
            decayRate: MILK_FROTHER_DECAY_RATE,
            decayPeriod: MILK_FROTHER_DECAY_PERIOD
        });
    }

    function create(
        uint256 _companyId,
        uint256 _type,
        string memory _uri
    ) external override onlyRole(SYSTEM_ROLE) returns (uint256) {
        require(
            _type == uint256(ProductItemType.BLACK_COFFEE) ||
                _type == uint256(ProductItemType.SUGAR_COFFEE) ||
                _type == uint256(ProductItemType.ESPRESSO) ||
                _type == uint256(ProductItemType.MILK_COFFEE) ||
                _type == uint256(ProductItemType.COFFEE_BEAN) ||
                _type == uint256(ProductItemType.MILK) ||
                _type == uint256(ProductItemType.SUGAR) ||
                _type == uint256(ProductItemType.WATER) ||
                _type == uint256(ProductItemType.GRINDER) ||
                _type == uint256(ProductItemType.KETTLE) ||
                _type == uint256(ProductItemType.MOKA_POT) ||
                _type == uint256(ProductItemType.MILK_FROTHER),
            "ProductItems: invalid type"
        );

        uint256 id = uint256(_type) * 1000 + _nextTokenId;
        _nextTokenId++;

        ProductItem memory item = productItems[id];
        item.energy = _newProductInfo[_type].energy;
        item.durability = _newProductInfo[_type].durability;
        item.decayRate = _newProductInfo[_type].decayRate;
        item.decayPeriod = _newProductInfo[_type].decayPeriod;
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

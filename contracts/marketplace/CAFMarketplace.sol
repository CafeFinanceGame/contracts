// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ICAFToken} from "../interfaces/ICAFToken.sol";
import {ICAFMarketplace} from "./ICAFMarketplace.sol";
import {ICAFResaleStore} from "./ICAFResaleStore.sol";
import {ICAFContractRegistry} from "../core/interfaces/ICAFContractRegistry.sol";
import {ICAFGameEconomy} from "../core/interfaces/ICAFGameEconomy.sol";
import {CAFAccessControl} from "../core/dependency/CAFAccessControl.sol";
import {ICAFItemsManager} from "../core/interfaces/ICAFItemsManager.sol";
import {ICAFGameManager} from "../core/interfaces/ICAFGameManager.sol";

import "hardhat/console.sol";

contract CAFMarketplace is
    CAFAccessControl,
    ICAFMarketplace,
    ICAFResaleStore,
    ReentrancyGuard
{
    ICAFToken private _cafToken;
    ICAFGameEconomy private _gameEconomy;
    ICAFItemsManager private _itemsManager;
    ICAFGameManager private _cafGameManager;

    uint256 private _lastAutoListed = block.timestamp;

    mapping(uint256 => ListedItem) public _listedItems;

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    modifier onlyOwner(uint256 _itemId) {
        require(
            _itemsManager.balanceOf(msg.sender, _itemId) > 0,
            "CAFMarketplace: item does not belong to the sender"
        );
        _;
    }

    modifier onlyNotListed(uint256 _itemId) {
        require(
            _listedItems[_itemId].price == 0,
            "CAFMarketplace: item is already listed"
        );
        _;
    }

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _cafToken = ICAFToken(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry.ContractRegistryType.CAF_TOKEN_CONTRACT
                )
            )
        );
        _gameEconomy = ICAFGameEconomy(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );
        _itemsManager = ICAFItemsManager(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_ITEMS_MANAGER_CONTRACT
                )
            )
        );
        _cafGameManager = ICAFGameManager(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_MANAGER_CONTRACT
                )
            )
        );
    }

    function buy(uint256 _itemId) external override {
        ListedItem storage item = _listedItems[_itemId];
        require(item.price > 0, "CAFMarketplace: item is not listed");
        require(
            _cafToken.balanceOf(msg.sender) >= item.price,
            "CAFMarketplace: insufficient balance"
        );

        _cafToken.transferFrom(msg.sender, item.owner, item.price);
        _itemsManager.safeTransferFrom(item.owner, msg.sender, _itemId, 1, "");

        delete _listedItems[_itemId];

        emit ItemBought(_itemId, msg.sender, item.owner, item.price);
    }

    function list(
        uint256 _itemId,
        uint256 _price
    ) external override onlyOwner(_itemId) onlyNotListed(_itemId) {
        require(_price > 0, "CAFMarketplace: price must be greater than zero");

        _listedItems[_itemId] = ListedItem({
            id: _itemId,
            owner: msg.sender,
            price: _price
        });

        emit ItemListed(_itemId, msg.sender, _price);
    }

    function unlist(uint256 _itemId) external override onlyOwner(_itemId) {
        delete _listedItems[_itemId];

        emit ItemUnlisted(_itemId, msg.sender);
    }

    function updatePrice(
        uint256 _itemId,
        uint256 _price
    ) external override onlyOwner(_itemId) {
        require(_price > 0, "CAFMarketplace: price must be greater than zero");

        _listedItems[_itemId].price = _price;

        emit ItemPriceUpdated(_itemId, msg.sender, _price);
    }

    function resell(uint256 _itemId) external override onlyOwner(_itemId) {
        _itemsManager.decay(_itemId);

        ICAFItemsManager.ProductItem memory item = _itemsManager.getProductItem(
            _itemId
        );

        require(item.expTime > block.timestamp, "CAFMarketplace: item expired");

        uint256 _price = calculateResalePrice(_itemId);

        require(_price > 0, "CAFMarketplace: item cannot be sold");

        _itemsManager.safeTransferFrom(
            msg.sender,
            address(_itemsManager),
            _itemId,
            1,
            ""
        );

        _listedItems[_itemId] = ListedItem({
            id: _itemId,
            owner: address(_itemsManager),
            price: _price
        });

        _cafGameManager.transferToken(msg.sender, _price);

        emit ItemResold(_itemId, msg.sender, _price);
    }

    function calculateResalePrice(
        uint256 _itemId
    ) public view override returns (uint256) {
        ICAFItemsManager.ProductItem memory item = _itemsManager.getProductItem(
            _itemId
        );

        if (item.expTime <= block.timestamp) {
            return 0;
        }

        ICAFGameEconomy.ProductEconomy memory itemEconomy = _gameEconomy
            .getProductEconomy(item.productType);

        uint256 _e0 = itemEconomy.energy;
        uint256 _d0 = itemEconomy.durability;
        uint256 _exp = item.expTime;

        uint256 _dF = (_d0 > 0) ? (uint256(item.durability) * 100) / _d0 : 0; // Weight 0.25
        uint256 _dW = 25;

        uint256 _eF = (_e0 > 0) ? (uint256(item.energy) * 100) / _e0 : 0; // Weight 0.25
        uint256 _eW = 25;

        uint256 _tF = (_exp > block.timestamp)
            ? ((_exp - block.timestamp) * 100) / (_exp - item.msgTime)
            : 0; // Weight 0.5
        uint256 _tW = 50;

        uint256 _price0 = _gameEconomy.getCurrentPrice(item.productType);

        return ((_eF * _eW + _dF * _dW + _tF * _tW) * _price0) / 10000;
    }

    function autoList() external override {
        require(
            block.timestamp - _lastAutoListed >= 1 hours,
            "CAFMarketplace: auto list is not available"
        );

        uint256 _listedItem = _itemsManager.popNotListedItem();

        while (_listedItem != 0) {
            if (_listedItems[_listedItem].price == 0) {
                _listedItem = _itemsManager.popNotListedItem();
                continue;
            }

            ICAFItemsManager.ProductItem memory item = _itemsManager
                .getProductItem(_listedItem);

            ICAFGameEconomy.ProductEconomy memory _itemEconomy = _gameEconomy
                .getProductEconomy(item.productType);

            uint256 _price = _itemEconomy.costPrice;

            if (_price > 0) {
                _listedItems[_listedItem] = ListedItem({
                    id: _listedItem,
                    owner: address(_itemsManager),
                    price: _price
                });

                emit ItemListed(_listedItem, address(_itemsManager), _price);
            }

            _listedItem = _itemsManager.popNotListedItem();
        }

        _lastAutoListed = block.timestamp;
    }
}

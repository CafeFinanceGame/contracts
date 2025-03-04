// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ICAFToken} from "../interfaces/ICAFToken.sol";
import {ICAFMarketplace} from "./ICAFMarketplace.sol";
import {ICAFResaleStore} from "./ICAFResaleStore.sol";
import {ICAFContractRegistry} from "../core/interfaces/ICAFContractRegistry.sol";
import {ICAFGameEconomy} from "../core/interfaces/ICAFGameEconomy.sol";
import {CAFProductItems} from "../core/items/CAFProductItems.sol";
import {CAFAccessControl} from "../core/dependency/CAFAccessControl.sol";

contract CAFMarketplace is
    CAFAccessControl,
    ICAFMarketplace,
    ICAFResaleStore,
    ReentrancyGuard
{
    ICAFToken private _cafToken;
    ICAFGameEconomy private _gameEconomy;
    CAFProductItems private _productItems;

    mapping(uint256 => ListedItem) public override listedItems;

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _productItems = CAFProductItems(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_PRODUCT_ITEMS_CONTRACT
                )
            )
        );
        _cafToken = ICAFToken(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry.ContractRegistryType.CAF_TOKEN_CONTRACT
                )
            )
        );
        _gameEconomy = ICAFGameEconomy(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_GAME_ECONOMY_CONTRACT
                )
            )
        );
    }

    function buy(uint256 _itemId) external override {
        ListedItem storage item = listedItems[_itemId];
        require(item.price > 0, "CAFMarketplace: item is not listed");
        require(
            _cafToken.balanceOf(msg.sender) >= item.price,
            "CAFMarketplace: insufficient balance"
        );

        _cafToken.transferFrom(msg.sender, item.owner, item.price);

        _productItems.safeTransferFrom(item.owner, msg.sender, item.id, 1, "");

        delete listedItems[_itemId];

        emit ItemBought(_itemId, msg.sender, item.owner, item.price);
    }

    function list(
        uint256 _itemId,
        uint256 _price
    ) external override onlyOwner(_itemId) {
        require(_price > 0, "CAFMarketplace: price must be greater than zero");

        listedItems[_itemId] = ListedItem({
            id: _itemId,
            owner: msg.sender,
            price: _price
        });

        emit ItemListed(_itemId, msg.sender, _price);
    }

    function unlist(uint256 _itemId) external override onlyOwner(_itemId) {
        delete listedItems[_itemId];

        emit ItemUnlisted(_itemId, msg.sender);
    }

    function updatePrice(
        uint256 _itemId,
        uint256 _price
    ) external override onlyOwner(_itemId) {
        require(_price > 0, "CAFMarketplace: price must be greater than zero");

        listedItems[_itemId].price = _price;

        emit ItemPriceUpdated(_itemId, msg.sender, _price);
    }

    function sell(uint256 _itemId) external override onlyOwner(_itemId) {
        CAFProductItems.ProductItem memory item = _productItems.get(_itemId);

        require(item.expTime > block.timestamp, "CAFMarketplace: item expired");

        uint256 _price = calculateResalePrice(_itemId);

        require(_price > 0, "CAFMarketplace: item cannot be sold");

        _productItems.safeTransferFrom(
            msg.sender,
            address(this),
            _itemId,
            1,
            ""
        );

        listedItems[_itemId] = ListedItem({
            id: _itemId,
            owner: msg.sender,
            price: _price
        });

        emit ItemResold(_itemId, msg.sender, _price);
    }

    function calculateResalePrice(
        uint256 _itemId
    ) public view override returns (uint256) {
        CAFProductItems.ProductItem memory item = _productItems.get(_itemId);

        if (item.expTime <= block.timestamp) {
            return 0;
        }

        ICAFGameEconomy.ProductEconomy memory itemEconomy = _gameEconomy
            .getProductEconomy(item.productType);

        uint256 _e0 = itemEconomy.energy;
        uint256 _d0 = itemEconomy.durability;
        uint256 _exp = item.expTime;

        uint256 _eF = (item.energy * 100) / _e0; // Weight 0.25
        uint256 _eW = 25;

        uint256 _dF = (item.durability * 100) / _d0; // Weight 0.25
        uint256 _dW = 25;

        uint256 _tF = ((_exp - block.timestamp) * 100) / item.expTime; // Weight 0.5
        uint256 _tW = 50;

        uint256 _price0 = _gameEconomy.getCurrentPrice(item.productType);

        return ((_eF * _eW + _dF * _dW + _tF * _tW) * _price0) / 100;
    }

    modifier onlyOwner(uint256 _itemId) {
        require(
            _productItems.balanceOf(msg.sender, _itemId) > 0,
            "CAFMarketplace: item does not belong to the sender"
        );
        _;
    }
}

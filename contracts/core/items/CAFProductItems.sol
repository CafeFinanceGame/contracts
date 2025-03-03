// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
import {ICAFManufacturableItems} from "../interfaces/ICAFManufacturableItems.sol";

contract CAFProductItems is
    ICAFProductItems,
    ICAFConsumableItems,
    ICAFManufacturableItems,
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

    ICAFCompanyItems private _companyItems;
    ICAFContractRegistry private _registry;
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
        _registry = ICAFContractRegistry(_contractRegistry);
        _companyItems = ICAFCompanyItems(
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
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
    }

    // ============================== MODIFIERS =========================================

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
        ItemLibrary.ProductItemType _type
    ) public override onlyRole(SYSTEM_ROLE) returns (uint256) {
        require(
            _companyItems.get(_companyId).owner != address(0),
            "ProductItems: company does not exist"
        );

        require(
            _type == ItemLibrary.ProductItemType.COFFEE_BEAN ||
                _type == ItemLibrary.ProductItemType.BLACK_COFFEE ||
                _type == ItemLibrary.ProductItemType.MILK_COFFEE ||
                _type == ItemLibrary.ProductItemType.POWDERED_MILK ||
                _type == ItemLibrary.ProductItemType.MILK ||
                _type == ItemLibrary.ProductItemType.WATER ||
                _type == ItemLibrary.ProductItemType.MACHINE_MATERIAL ||
                _type == ItemLibrary.ProductItemType.KETTLE ||
                _type == ItemLibrary.ProductItemType.MILK_FROTHER,
            "ProductItems: invalid type"
        );

        uint256 id = uint256(
            keccak256(abi.encodePacked(_type, block.timestamp))
        );

        ICAFGameEconomy.ProductEconomy memory productEconomy = _gameEconomy
            .getProductEconomy(_type);

        ProductItem memory item = ProductItem({
            productType: _type,
            price: 0,
            energy: productEconomy.energy,
            durability: productEconomy.durability,
            decayPeriod: productEconomy.decayPeriod,
            decayRate: productEconomy.decayRate,
            lastDecayTime: block.timestamp
        });

        item.lastDecayTime = block.timestamp;

        productItems[id] = item;

        _mint(msg.sender, id, 1, "");

        return id;
    }

    function createBatch(
        ItemLibrary.ProductItemType _type,
        uint256 _amount
    ) external override onlyRole(SYSTEM_ROLE) returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](_amount);

        for (uint256 i = 0; i < _amount; i++) {
            ids[i] = uint256(
                keccak256(abi.encodePacked(_type, block.timestamp))
            );
        }

        address to = _registry.getContractAddress(
            uint256(
                ICAFContractRegistry
                    .ContractRegistryType
                    .CAF_PRODUCT_ITEMS_CONTRACT
            )
        );

        uint256[] memory values = new uint256[](_amount);
        for (uint256 i = 0; i < _amount; i++) {
            values[i] = 1;
        }

        _mintBatch(to, ids, values, "");

        return ids;
    }

    function updateProductItem(
        uint256 _itemId,
        uint256 _price,
        uint256 _energy,
        uint256 _durability,
        uint256 _decayPeriod,
        uint8 _decayRate
    ) external override onlyRole(SYSTEM_ROLE) {
        ProductItem storage item = productItems[_itemId];
        item.price = _price;
        item.energy = _energy;
        item.durability = _durability;
        item.decayPeriod = _decayPeriod;
        item.decayRate = _decayRate;
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

    function manufacture(
        ItemLibrary.ProductItemType _productType,
        uint256[] memory _componentIds
    ) external override returns (uint256) {
        require(
            _productType == ItemLibrary.ProductItemType.BLACK_COFFEE ||
                _productType == ItemLibrary.ProductItemType.MILK_COFFEE ||
                _productType == ItemLibrary.ProductItemType.MILK_FROTHER ||
                _productType == ItemLibrary.ProductItemType.KETTLE,
            "ProductItems: product type is not manufacturable"
        );

        uint256 _companyId = _companyItems.getByOwner(msg.sender);

        require(_companyId != 0, "ProductItems: company does not exist");

        // Manufacture the black coffee
        if (_productType == ItemLibrary.ProductItemType.BLACK_COFFEE) {
            require(
                _componentIds.length == 3,
                "ProductItems: invalid component count"
            );

            uint256 coffeeBeanId;
            uint256 waterId;
            uint256 kettleId;
            bool hasCoffeeBean = false;
            bool hasWater = false;
            bool hasKettle = false;

            for (uint256 i = 0; i < _componentIds.length; i++) {
                ItemLibrary.ProductItemType itemType = productItems[
                    _componentIds[i]
                ].productType;

                if (
                    itemType == ItemLibrary.ProductItemType.COFFEE_BEAN &&
                    !hasCoffeeBean
                ) {
                    coffeeBeanId = _componentIds[i];
                    hasCoffeeBean = true;
                } else if (
                    itemType == ItemLibrary.ProductItemType.WATER && !hasWater
                ) {
                    waterId = _componentIds[i];
                    hasWater = true;
                } else if (
                    itemType == ItemLibrary.ProductItemType.KETTLE && !hasKettle
                ) {
                    kettleId = _componentIds[i];
                    hasKettle = true;
                }
            }

            require(
                hasCoffeeBean && hasWater && hasKettle,
                "ProductItems: missing required components"
            );
            require(
                balanceOf(msg.sender, coffeeBeanId) >= 1 &&
                    balanceOf(msg.sender, waterId) >= 1 &&
                    balanceOf(msg.sender, kettleId) >= 1,
                "ProductItems: insufficient balance"
            );

            // Decay the components
            decay(coffeeBeanId);
            decay(waterId);
            decay(kettleId);

            // Calculate the energy of the black coffee
            uint256 _energy = calculateEnergy(_componentIds);

            uint256 id = create(_companyId, _productType);

            productItems[id].energy = uint8(_energy);

            return id;
        }

        // Manufacture the milk coffee
        if (_productType == ItemLibrary.ProductItemType.MILK_COFFEE) {
            require(
                _componentIds.length == 2,
                "ProductItems: invalid component count"
            );

            uint256 blackCoffeeId;
            uint256 milkId;
            bool hasBlackCoffee = false;
            bool hasMilk = false;

            for (uint256 i = 0; i < _componentIds.length; i++) {
                ItemLibrary.ProductItemType itemType = productItems[
                    _componentIds[i]
                ].productType;

                if (
                    itemType == ItemLibrary.ProductItemType.BLACK_COFFEE &&
                    !hasBlackCoffee
                ) {
                    blackCoffeeId = _componentIds[i];
                    hasBlackCoffee = true;
                } else if (
                    itemType == ItemLibrary.ProductItemType.MILK && !hasMilk
                ) {
                    milkId = _componentIds[i];
                    hasMilk = true;
                }
            }

            require(
                hasBlackCoffee && hasMilk,
                "ProductItems: missing required components"
            );
            require(
                balanceOf(msg.sender, blackCoffeeId) >= 1 &&
                    balanceOf(msg.sender, milkId) >= 1,
                "ProductItems: insufficient balance"
            );

            // Decay the components
            decay(blackCoffeeId);
            decay(milkId);

            // Calculate the energy of the milk coffee
            uint256 _energy = calculateEnergy(_componentIds);

            uint256 id = create(_companyId, _productType);

            productItems[id].energy = uint8(_energy);

            return id;
        }

        // Manufacture the milk frother
        if (_productType == ItemLibrary.ProductItemType.MILK_FROTHER) {
            require(
                _componentIds.length == 1,
                "ProductItems: invalid component count"
            );

            uint256 machineMaterialId;
            bool hasMachineMaterial = false;

            for (uint256 i = 0; i < _componentIds.length; i++) {
                ItemLibrary.ProductItemType itemType = productItems[
                    _componentIds[i]
                ].productType;

                if (
                    itemType == ItemLibrary.ProductItemType.MACHINE_MATERIAL &&
                    !hasMachineMaterial
                ) {
                    machineMaterialId = _componentIds[i];
                    hasMachineMaterial = true;
                }
            }

            require(
                hasMachineMaterial,
                "ProductItems: missing required components"
            );
            require(
                balanceOf(msg.sender, machineMaterialId) >= 1,
                "ProductItems: insufficient balance"
            );

            // Decay the components
            decay(machineMaterialId);

            // Calculate the energy of the milk frother
            uint256 _durability = calculateDurability(_componentIds);

            uint256 id = create(_companyId, _productType);

            productItems[id].durability = uint8(_durability);

            return id;
        }

        // Manufacture the kettle
        if (_productType == ItemLibrary.ProductItemType.KETTLE) {
            require(
                _componentIds.length == 1,
                "ProductItems: invalid component count"
            );

            uint256 machineMaterialId;
            bool hasMachineMaterial = false;

            for (uint256 i = 0; i < _componentIds.length; i++) {
                ItemLibrary.ProductItemType itemType = productItems[
                    _componentIds[i]
                ].productType;

                if (
                    itemType == ItemLibrary.ProductItemType.MACHINE_MATERIAL &&
                    !hasMachineMaterial
                ) {
                    machineMaterialId = _componentIds[i];
                    hasMachineMaterial = true;
                }
            }

            require(
                hasMachineMaterial,
                "ProductItems: missing required components"
            );
            require(
                balanceOf(msg.sender, machineMaterialId) >= 1,
                "ProductItems: insufficient balance"
            );

            // Decay the components
            decay(machineMaterialId);

            // Calculate the energy of the kettle
            uint256 _durability = calculateDurability(_componentIds);

            uint256 id = create(_companyId, _productType);

            productItems[id].durability = uint8(_durability);

            return id;
        }

        return 0;
    }

    function calculateEnergy(
        uint256[] memory _componentIds
    ) public view override returns (uint256) {
        uint256 totalEnergy = 0;
        uint256 K = 90; // Energy coefficient adjusts the final energy of the manufactured product based on component energy and decay

        for (uint256 i = 0; i < _componentIds.length; i++) {
            uint256 itemId = _componentIds[i];
            ProductItem storage item = productItems[itemId];

            // Tính phần energy còn lại sau decay
            uint256 timePassed = block.timestamp - item.lastDecayTime;
            uint256 decayFactor = (timePassed >= item.decayPeriod)
                ? 0
                : ((item.decayPeriod - timePassed) * 100) / item.decayPeriod;

            uint256 effectiveEnergy = (item.energy * decayFactor) / 100;
            totalEnergy += effectiveEnergy;
        }

        return (totalEnergy * K) / 100;
    }

    function calculateDurability(
        uint256[] memory _componentIds
    ) public view override returns (uint256) {
        uint256 totalDurability = 0;
        uint256 K_d = 160; // Durability coefficient determines the durability of manufactured machines or tools

        for (uint256 i = 0; i < _componentIds.length; i++) {
            uint256 itemId = _componentIds[i];
            ProductItem storage item = productItems[itemId];

            uint256 timePassed = block.timestamp - item.lastDecayTime;
            uint256 decayFactor = (timePassed >= item.decayPeriod)
                ? 0
                : ((item.decayPeriod - timePassed) * 100) / item.decayPeriod;

            uint256 effectiveDurability = (item.durability * decayFactor) / 100;
            totalDurability += effectiveDurability;
        }

        return (totalDurability * K_d) / 100;
    }
}

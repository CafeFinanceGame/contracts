// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ItemLibrary} from "../libraries/ItemLibrary.sol";
import {ICAFItemsManager} from "../interfaces/ICAFItemsManager.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {CAFModuleBase} from "../dependency/CAFModuleBase.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "hardhat/console.sol";

contract CAFItemsManager is
    ICAFItemsManager,
    ERC1155,
    ERC1155Holder,
    CAFModuleBase
{
    using Strings for uint256;

    ICAFGameEconomy private _gameEconomy;

    uint256 private _nextItemId = 1;
    uint256 private _lastProducedTime = block.timestamp;
    uint256 private _lastDecayTime = block.timestamp;

    mapping(uint256 => address) private _itemOwners;
    mapping(uint256 => ProductItem) private _productItems;
    mapping(uint256 => CompanyItem) private _companyItems;
    mapping(uint256 => EventItem) private _eventItems;
    mapping(uint256 => bool) private _activeEvents;
    mapping(address => uint256) private _ownerOwnedCompany;
    mapping(uint256 => uint256[]) private _companyOwnedItems;
    mapping(ItemLibrary.ProductItemType => ProductRecipe)
        private _productRecipes;

    uint256[] private _notListedItems; // only for items owned by the system
    uint256[] private _allProductItemIds;
    uint256[] private _allCompanyItemIds;
    uint256[] private _allEventItemIds;

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        override(IERC165, ERC1155, ERC1155Holder, CAFModuleBase)
        returns (bool)
    {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC1155).interfaceId;
    }

    constructor(
        address _contractRegistry
    )
        ERC1155("https://cafigame.vercel.app/api/items/{id}.json")
        CAFModuleBase(_contractRegistry)
    {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(SYSTEM_ROLE, address(this));

        _createCompanyItem(
            address(this),
            ItemLibrary.CompanyType.FACTORY_COMPANY
        );

        _productRecipes[ItemLibrary.ProductItemType.COFFEE] = ProductRecipe({
            output: ItemLibrary.ProductItemType.COFFEE,
            inputs: new ItemLibrary.ProductItemType[](3)
        });
        _productRecipes[ItemLibrary.ProductItemType.COFFEE].inputs[
                0
            ] = ItemLibrary.ProductItemType.COFFEE_BEAN;
        _productRecipes[ItemLibrary.ProductItemType.COFFEE].inputs[
                1
            ] = ItemLibrary.ProductItemType.WATER;
        _productRecipes[ItemLibrary.ProductItemType.COFFEE].inputs[
                2
            ] = ItemLibrary.ProductItemType.KETTLE;

        _productRecipes[ItemLibrary.ProductItemType.MILK] = ProductRecipe({
            output: ItemLibrary.ProductItemType.MILK,
            inputs: new ItemLibrary.ProductItemType[](2)
        });
        _productRecipes[ItemLibrary.ProductItemType.MILK].inputs[
            0
        ] = ItemLibrary.ProductItemType.WATER;
        _productRecipes[ItemLibrary.ProductItemType.MILK].inputs[
            1
        ] = ItemLibrary.ProductItemType.KETTLE;

        _productRecipes[ItemLibrary.ProductItemType.KETTLE] = ProductRecipe({
            output: ItemLibrary.ProductItemType.KETTLE,
            inputs: new ItemLibrary.ProductItemType[](2)
        });
        _productRecipes[ItemLibrary.ProductItemType.KETTLE].inputs[
                0
            ] = ItemLibrary.ProductItemType.MACHINE_MATERIAL;
        _productRecipes[ItemLibrary.ProductItemType.KETTLE].inputs[
                1
            ] = ItemLibrary.ProductItemType.WATER;
    }

    modifier onlyHasAccess() {
        require(
            hasRole(SYSTEM_ROLE, msg.sender) || hasRole(ADMIN_ROLE, msg.sender),
            "CAFItemsManager: caller is not the system or admin"
        );
        _;
    }

    modifier onlyCompanyOwner(uint256 _companyId) {
        require(
            _companyItems[_companyId].owner == msg.sender,
            "CAFItemsManager: caller is not the company owner"
        );
        _;
    }

    modifier onlyCompanyRole(
        uint256 _companyId,
        ItemLibrary.CompanyType _role
    ) {
        require(
            _companyItems[_companyId].role == _role,
            "CAFItemsManager: caller is not the company role"
        );
        _;
    }

    modifier onlyCompanyExists(uint256 _companyId) {
        require(
            _companyItems[_companyId].owner != address(0),
            "CAFItemsManager: company does not exist"
        );
        _;
    }

    modifier onlyEventExists(uint256 _eventId) {
        require(
            _eventItems[_eventId].eventType !=
                ItemLibrary.EventItemType.UNKNOWN,
            "CAFItemsManager: event does not exist"
        );
        _;
    }

    modifier onlyProductItemExists(uint256 _itemId) {
        require(
            _productItems[_itemId].productType !=
                ItemLibrary.ProductItemType.UNKNOWN,
            "CAFItemsManager: product item does not exist"
        );
        _;
    }

    function setUp() external override onlyRole(ADMIN_ROLE) {
        _grantRole(
            SYSTEM_ROLE,
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MARKETPLACE_CONTRACT
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

        _setApprovalForAll(
            address(this),
            _registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MARKETPLACE_CONTRACT
                )
            ),
            true
        );
    }

    function getNextItemId() external view override returns (uint256) {
        return _nextItemId;
    }

    function _calculateExpTime(
        uint256 _unit,
        uint256 _mfgTime,
        uint256 _decayRatePerQuarterDay
    ) private pure returns (uint256) {
        return _mfgTime + ((1 hours) * _unit) / _decayRatePerQuarterDay;
    }

    function _createProductItem(
        uint256 _companyId,
        ProductItem memory _productItem
    ) private onlyCompanyExists(_companyId) returns (uint256, address) {
        CompanyItem memory _company = getCompanyItem(_companyId);
        uint256 _productId = _nextItemId++;

        _productItems[_productId] = _productItem;

        _companyOwnedItems[_companyId].push(_productId);
        _itemOwners[_productId] = _company.owner;
        _allProductItemIds.push(_productId);

        return (_productId, _company.owner);
    }

    function createProductItem(
        uint256 _companyId,
        ItemLibrary.ProductItemType _productType
    ) public override onlyHasAccess onlyCompanyExists(_companyId) {
        ICAFGameEconomy.ProductEconomy memory _productEconomy = _gameEconomy
            .getProductEconomy(_productType);

        uint256 _unit = (_productEconomy.energy > 0)
            ? _productEconomy.energy
            : _productEconomy.durability;
        (uint256 _productId, address _owner) = _createProductItem(
            _companyId,
            ProductItem({
                productType: _productType,
                energy: _productEconomy.energy,
                durability: _productEconomy.durability,
                decayRatePerQuarterDay: _productEconomy.decayRatePerQuarterDay,
                mfgTime: block.timestamp,
                expTime: _calculateExpTime(
                    _unit,
                    block.timestamp,
                    _productEconomy.decayRatePerQuarterDay
                ),
                lastDecayTime: block.timestamp
            })
        );

        _mint(_owner, _productId, 1, "");

        emit ProductItemCreated(_productId, _companyId);
    }

    function _createCompanyItem(
        address _owner,
        ItemLibrary.CompanyType _role
    ) internal returns (uint256) {
        require(
            _role != ItemLibrary.CompanyType.UNKNOWN,
            "CAFItemsManager: CompanyItem role must be a valid role"
        );

        require(
            _owner != address(0),
            "CAFItemsManager: CompanyItem owner cannot be the zero address"
        );

        require(
            _role != ItemLibrary.CompanyType.FACTORY_COMPANY ||
                hasRole(SYSTEM_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "CAFItemsManager: Factory company role is only for the system"
        );

        require(
            _ownerOwnedCompany[_owner] == 0,
            "CAFItemsManager: CompanyItem already exists for this owner"
        );

        uint256 _companyId = _nextItemId++;

        _companyItems[_companyId] = CompanyItem({
            owner: _owner,
            role: _role,
            energy: 100
        });

        _ownerOwnedCompany[_owner] = _companyId;
        _companyOwnedItems[_companyId] = new uint256[](0);
        _itemOwners[_companyId] = _owner;
        _allCompanyItemIds.push(_companyId);

        _mint(_owner, _companyId, 1, "");

        emit CompanyItemCreated(_companyId, _owner);

        return _companyId;
    }

    function createCompanyItem(
        address _owner,
        ItemLibrary.CompanyType _role
    ) public override {
        _createCompanyItem(_owner, _role);
    }

    function createEventItem(
        ItemLibrary.EventItemType _eventType,
        uint256 _startDate,
        uint256 _endDate
    ) external override onlyHasAccess {
        uint256 _eventId = _nextItemId++;

        _eventItems[_eventId] = EventItem({
            eventType: _eventType,
            startDate: _startDate,
            endDate: _endDate
        });

        _mint(msg.sender, _eventId, 1, "");

        _allEventItemIds.push(_eventId);
        _activeEvents[_eventId] = false;

        emit EventItemCreated(_eventId, _eventType);
    }

    function produceProducts(
        ItemLibrary.ProductItemType _productType,
        uint256 _ratePerQuarterDay // The rate produced per hour
    ) public override onlyHasAccess {
        require(
            _ratePerQuarterDay > 0,
            "CAFItemsManager: rate produced per hour must be greater than zero"
        );
        require(
            _productType != ItemLibrary.ProductItemType.UNKNOWN,
            "CAFItemsManager: product type must be a valid product type"
        );

        uint256 _deltaT = block.timestamp - _lastProducedTime;
        uint256 _quantityProduced = (_deltaT * _ratePerQuarterDay) /
            (1 days / 4);

        ICAFGameEconomy.ProductEconomy memory _productEconomy = _gameEconomy
            .getProductEconomy(_productType);

        uint256[] memory _productIds = new uint256[](_quantityProduced);
        uint256[] memory _minBatchValues = new uint256[](_quantityProduced);

        for (uint256 i = 0; i < _quantityProduced; i++) {
            (uint256 _productId, address _owner) = _createProductItem(
                _ownerOwnedCompany[address(this)],
                ProductItem({
                    productType: _productType,
                    energy: _productEconomy.energy,
                    durability: _productEconomy.durability,
                    decayRatePerQuarterDay: _productEconomy
                        .decayRatePerQuarterDay,
                    mfgTime: block.timestamp,
                    expTime: _calculateExpTime(
                        _productEconomy.energy,
                        block.timestamp,
                        _productEconomy.decayRatePerQuarterDay
                    ),
                    lastDecayTime: block.timestamp
                })
            );

            _productIds[i] = _productId;
            _minBatchValues[i] = 1;
            _notListedItems.push(_productId);

            emit ProductItemCreated(_productId, _ownerOwnedCompany[_owner]);
        }

        _mintBatch(address(this), _productIds, _minBatchValues, "");

        emit ProductsProduced(_productType, _quantityProduced);
    }

    function getProductItem(
        uint256 _itemId
    ) public view override returns (ProductItem memory) {
        return _productItems[_itemId];
    }

    function getAllProductItemIds()
        external
        view
        override
        returns (uint256[] memory)
    {
        return _allProductItemIds;
    }

    function getAllProductItemByOwner(
        address _owner
    ) external view override returns (uint256[] memory) {
        return _companyOwnedItems[_ownerOwnedCompany[_owner]];
    }

    function hasProductItem(
        address _owner,
        uint256 _itemId
    ) external view override returns (bool) {
        return _itemOwners[_itemId] == _owner;
    }

    function getCompanyItem(
        uint256 _companyId
    ) public view override returns (CompanyItem memory) {
        return _companyItems[_companyId];
    }

    function getCompanyItemByOwner(
        address _owner
    ) external view override returns (uint256) {
        return _ownerOwnedCompany[_owner];
    }

    function hasCompanyItem(
        address _owner
    ) external view override returns (bool) {
        return _ownerOwnedCompany[_owner] != 0;
    }

    function getAllCompanyItemIds()
        external
        view
        override
        returns (uint256[] memory)
    {
        return _allCompanyItemIds;
    }

    function getEventItem(
        uint256 _eventId
    ) external view override returns (EventItem memory) {
        return _eventItems[_eventId];
    }

    function getAllEventItemIds()
        external
        view
        override
        returns (uint256[] memory)
    {
        return _allEventItemIds;
    }

    function getAllActiveEventItemIds()
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory _activeEventIds = new uint256[](
            _allEventItemIds.length
        );
        uint256 _activeEventCount = 0;

        for (uint256 i = 0; i < _allEventItemIds.length; i++) {
            if (_activeEvents[i]) {
                _activeEventIds[_activeEventCount++] = i;
            }
        }

        return _activeEventIds;
    }

    function _popNotListedItem() internal returns (uint256) {
        uint256 _listedItemId = _notListedItems[_notListedItems.length - 1];
        _notListedItems.pop();

        return _listedItemId;
    }

    function popNotListedItem()
        external
        override
        onlyHasAccess
        returns (uint256)
    {
        if (_notListedItems.length == 0) {
            return 0;
        }

        return _popNotListedItem();
    }

    function _calculateEnergy(
        uint256[] memory _componentIds
    ) private view returns (uint8) {
        uint8 _totalEnergy = 0;
        for (uint256 i = 0; i < _componentIds.length; i++) {
            ProductItem memory _productItem = getProductItem(_componentIds[i]);
            _totalEnergy += _productItem.energy;
        }

        return uint8(_totalEnergy / _componentIds.length);
    }

    function _calculateDurability(
        uint256[] memory _componentIds
    ) private view returns (uint8) {
        uint8 _totalDurability = 0;
        for (uint256 i = 0; i < _componentIds.length; i++) {
            ProductItem memory _productItem = getProductItem(_componentIds[i]);
            _totalDurability += _productItem.durability;
        }

        return uint8(_totalDurability / _componentIds.length);
    }

    function manufacture(
        ItemLibrary.ProductItemType _productType,
        uint256[] memory _componentIds
    ) external override returns (uint256) {
        ProductRecipe memory _productRecipe = _productRecipes[_productType];
        CompanyItem memory _company = getCompanyItem(
            _ownerOwnedCompany[msg.sender]
        );

        require(
            _productType != ItemLibrary.ProductItemType.UNKNOWN,
            "CAFItemsManager: product type must be a valid product type"
        );

        require(
            _productType == ItemLibrary.ProductItemType.COFFEE ||
                _productType == ItemLibrary.ProductItemType.MILK ||
                _productType == ItemLibrary.ProductItemType.KETTLE,
            "CAFItemsManager: product type must be a valid manufacturable product type"
        );

        require(
            _componentIds.length == _productRecipe.inputs.length,
            "CAFItemsManager: Incorrect number of components"
        );

        require(
            _company.energy >=
                _gameEconomy
                    .getActivityFee(
                        ICAFGameEconomy
                            .CompanyAcitivityEnergyFeeType
                            .MANUFACTURE
                    )
                    .fee,
            "CAFItemsManager: CompanyItem does not have enough energy"
        );

        uint8 _enoughComponents = 0;

        for (uint256 i = 0; i < _componentIds.length; i++) {
            decay(_componentIds[i]);

            ProductItem memory _componentItem = getProductItem(
                _componentIds[i]
            );

            if (_componentItem.productType == _productRecipe.inputs[i]) {
                _enoughComponents++;
            }
        }

        require(
            _enoughComponents == _componentIds.length,
            "CAFItemsManager: Incorrect recipe"
        );

        uint256 _itemId = _nextItemId++;

        ICAFGameEconomy.ProductEconomy memory _productEconomy = _gameEconomy
            .getProductEconomy(_productType);

        uint8 _energy = (_productEconomy.energy > 0)
            ? _calculateEnergy(_componentIds)
            : _productEconomy.energy;
        uint8 _durability = (_productEconomy.durability > 0)
            ? _calculateDurability(_componentIds)
            : _productEconomy.durability;

        (uint256 _productId, address _owner) = _createProductItem(
            _ownerOwnedCompany[msg.sender],
            ProductItem({
                productType: _productType,
                energy: _energy,
                durability: _durability,
                decayRatePerQuarterDay: _productEconomy.decayRatePerQuarterDay,
                mfgTime: block.timestamp,
                expTime: _calculateExpTime(
                    _energy,
                    block.timestamp,
                    _productEconomy.decayRatePerQuarterDay
                ),
                lastDecayTime: block.timestamp
            })
        );

        _mint(_owner, _productId, 1, "");

        uint8 _activityFee = _gameEconomy
            .getActivityFee(
                ICAFGameEconomy.CompanyAcitivityEnergyFeeType.MANUFACTURE
            )
            .fee;

        useEnergy(_ownerOwnedCompany[msg.sender], uint8(_activityFee));

        emit ProductItemManufactured(_itemId, _productType);

        return _itemId;
    }

    function replenishEnergy(
        uint256 _companyId,
        uint256 _itemId
    ) external override onlyCompanyOwner(_companyId) {
        CompanyItem storage _company = _companyItems[_companyId];
        ProductItem storage _productItem = _productItems[_itemId];

        require(
            _company.energy < 100,
            "CAFItemsManager: company already has full energy"
        );

        require(
            _productItem.energy > 0,
            "CAFItemsManager: product item does not have enough energy"
        );

        uint256 availableEnergy = 100 - uint256(_company.energy);

        uint8 _energy = (_productItem.energy > uint8(availableEnergy))
            ? uint8(availableEnergy)
            : uint8(_productItem.energy);

        _company.energy = uint8(uint256(_company.energy) + _energy);
        _productItem.energy -= _energy;

        emit EnergyReplenished(_companyId, _energy);
    }

    function useEnergy(uint256 _companyId, uint8 _amount) public override {
        require(
            hasRole(SYSTEM_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender) ||
                _companyItems[_companyId].owner == msg.sender,
            "CAFItemsManager: caller is not the system, admin or company owner"
        );

        CompanyItem storage _company = _companyItems[_companyId];

        require(
            _company.energy >= _amount,
            "CAFItemsManager: company does not have enough energy"
        );

        _company.energy -= _amount;

        emit EnergyUsed(_companyId, _amount);
    }

    function startEvent(
        uint256 _eventId
    ) external override onlyEventExists(_eventId) {
        EventItem memory _eventItem = _eventItems[_eventId];

        require(
            _eventItem.startDate <= block.timestamp,
            "CAFItemsManager: event has not started yet"
        );

        require(
            _eventItem.endDate > block.timestamp,
            "CAFItemsManager: event has ended"
        );

        _activeEvents[_eventId] = true;

        emit EventItemStarted(_eventId);
    }

    function endEvent(uint256 _eventId) external override {
        EventItem memory _eventItem = _eventItems[_eventId];

        require(
            _eventItem.endDate <= block.timestamp,
            "CAFItemsManager: event has not ended yet"
        );

        _activeEvents[_eventId] = false;

        emit EventItemEnded(_eventId);
    }

    function uri(uint256 _id) public pure override returns (string memory) {
        string memory _baseURI = "https://cafigame.vercel.app/api/items/";
        return string(abi.encodePacked(_baseURI, _id.toString(), ".json"));
    }

    function decay(uint256 _itemId) public override returns (uint256) {
        ProductItem storage _productItem = _productItems[_itemId];

        if (_productItem.expTime <= block.timestamp) {
            _burn(_itemOwners[_itemId], _itemId, 1);
            delete _productItems[_itemId];
            return 0;
        }

        if (block.timestamp < _productItem.lastDecayTime + 1 days / 4) {
            return 0;
        }

        uint256 _decayRatePerQuarterDay = _gameEconomy
            .getProductEconomy(_productItem.productType)
            .decayRatePerQuarterDay;

        uint256 _deltaT = (block.timestamp - _productItem.lastDecayTime) /
            1 hours;

        uint256 _rDecay = _decayRatePerQuarterDay;

        uint256 _decayAmount = _rDecay * _deltaT;

        _productItem.energy = (_productItem.energy > _decayAmount)
            ? uint8(_productItem.energy - _decayAmount)
            : 0;
        _productItem.durability = (_productItem.durability > _decayAmount)
            ? uint8(_productItem.durability - _decayAmount)
            : 0;

        _productItem.lastDecayTime = block.timestamp;

        return _decayAmount;
    }

    function autoProduceProducts() external override onlyHasAccess {
        require(
            _lastProducedTime + (1 days / 4) <= block.timestamp,
            "CAFItemsManager: Products are already being produced or not ready for productions"
        );

        ItemLibrary.ProductItemType[]
            memory _productTypes = new ItemLibrary.ProductItemType[](3);

        _productTypes[0] = ItemLibrary.ProductItemType.COFFEE_BEAN;
        _productTypes[1] = ItemLibrary.ProductItemType.WATER;
        _productTypes[2] = ItemLibrary.ProductItemType.MACHINE_MATERIAL;

        for (uint256 i = 0; i < _productTypes.length; i++) {
            ICAFGameEconomy.ManufacturedProduct
                memory _manufacturedProductEconomy = _gameEconomy
                    .getManufacturedProduct(_productTypes[i]);
            uint256 _economyRate = _manufacturedProductEconomy
                .manufacturedPerQuarterDay;

            produceProducts(
                ItemLibrary.ProductItemType(_productTypes[i]),
                _economyRate
            );
        }

        _lastProducedTime = block.timestamp;

        emit AllAutoProductsProduced(_lastProducedTime);
    }

    function autoDecayAll() external override onlyHasAccess {
        for (uint256 i = 0; i < _allProductItemIds.length; i++) {
            decay(_allProductItemIds[i]);
        }

        _lastDecayTime = block.timestamp;

        emit AllItemsDecayed(_lastDecayTime);
    }

    function getLastAutoProduceProducts()
        external
        view
        override
        returns (uint256)
    {
        return _lastProducedTime;
    }

    function getLastAutoDecayTime() external view override returns (uint256) {
        return _lastDecayTime;
    }
}

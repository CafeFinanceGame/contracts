// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CAFAccessControl} from "../dependency/CAFAccessControl.sol";
import {ICAFGameEconomy} from "../interfaces/ICAFGameEconomy.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";

contract CAFGameEconomy is ICAFGameEconomy, CAFAccessControl {
    mapping(ItemLibrary.ProductItemType => ProductEconomy) private _products;
    mapping(ItemLibrary.ProductItemType => ManufacturedProduct)
        private _manufacturedProducts;
    mapping(CompanyAcitivityEnergyFeeType => ActivityEnergyFee)
        private _activityFees;
    mapping(ItemLibrary.ProductItemType => uint256) private _cachedPrices;
    mapping(ItemLibrary.ProductItemType => uint256) private _lastUpdatedBlock;

    constructor(address _contractRegistry) CAFAccessControl(_contractRegistry) {
        _initializeProducts();
    }

    function _initializeProducts() internal {
        _products[ItemLibrary.ProductItemType.COFFEE_BEAN] = ProductEconomy(
            80,
            0,
            4,
            5
        );
        _products[ItemLibrary.ProductItemType.COFFEE] = ProductEconomy(
            100,
            0,
            8,
            10
        );

        _products[ItemLibrary.ProductItemType.MILK] = ProductEconomy(
            100,
            0,
            8,
            8
        );
        _products[ItemLibrary.ProductItemType.WATER] = ProductEconomy(
            80,
            0,
            4,
            3
        );
        _products[ItemLibrary.ProductItemType.KETTLE] = ProductEconomy(
            0,
            80,
            1,
            40
        );

        _products[
            ItemLibrary.ProductItemType.MACHINE_MATERIAL
        ] = ProductEconomy(0, 100, 1, 50);

        _manufacturedProducts[
            ItemLibrary.ProductItemType.COFFEE_BEAN
        ] = ManufacturedProduct(2);
        _manufacturedProducts[
            ItemLibrary.ProductItemType.WATER
        ] = ManufacturedProduct(3);
        _manufacturedProducts[
            ItemLibrary.ProductItemType.MACHINE_MATERIAL
        ] = ManufacturedProduct(1);

        _activityFees[
            CompanyAcitivityEnergyFeeType.MANUFACTURE
        ] = ActivityEnergyFee(CompanyAcitivityEnergyFeeType.MANUFACTURE, 5);

        _activityFees[CompanyAcitivityEnergyFeeType.BUY] = ActivityEnergyFee(
            CompanyAcitivityEnergyFeeType.BUY,
            2
        );

        _activityFees[CompanyAcitivityEnergyFeeType.RESELL] = ActivityEnergyFee(
            CompanyAcitivityEnergyFeeType.RESELL,
            2
        );

        _activityFees[CompanyAcitivityEnergyFeeType.LIST] = ActivityEnergyFee(
            CompanyAcitivityEnergyFeeType.LIST,
            2
        );

        _activityFees[CompanyAcitivityEnergyFeeType.UNLIST] = ActivityEnergyFee(
            CompanyAcitivityEnergyFeeType.UNLIST,
            2
        );

        _activityFees[CompanyAcitivityEnergyFeeType.UPDATE] = ActivityEnergyFee(
            CompanyAcitivityEnergyFeeType.UPDATE,
            2
        );
    }

    function updateProductEconomy(
        ItemLibrary.ProductItemType _productType,
        uint256 _energy,
        uint256 _durability,
        uint8 _decayRatePerHour,
        uint256 _costPrice
    ) external override returns (bool) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "CAFGameEconomy: must have admin role"
        );

        _products[_productType] = ProductEconomy(
            uint8(_energy),
            uint8(_durability),
            _decayRatePerHour,
            _costPrice
        );

        return true;
    }

    function getCurrentPrice(
        ItemLibrary.ProductItemType _productType
    ) public view override returns (uint256) {
        if (_lastUpdatedBlock[_productType] == block.number) {
            return _cachedPrices[_productType];
        }
        return _calculatePrice(_productType);
    }

    function _calculatePrice(
        ItemLibrary.ProductItemType _productType
    ) internal view returns (uint256) {
        ProductEconomy memory _product = _products[_productType];
        return _product.costPrice;
    }

    function _updatePriceCache(
        ItemLibrary.ProductItemType _productType
    ) internal {
        _cachedPrices[_productType] = getCurrentPrice(_productType);
        _lastUpdatedBlock[_productType] = block.number;
    }

    function updateAllPrices() external onlyRole(SYSTEM_ROLE) {
        ItemLibrary.ProductItemType[6] memory productTypes = [
            ItemLibrary.ProductItemType.COFFEE_BEAN,
            ItemLibrary.ProductItemType.COFFEE,
            ItemLibrary.ProductItemType.WATER,
            ItemLibrary.ProductItemType.MILK,
            ItemLibrary.ProductItemType.MACHINE_MATERIAL,
            ItemLibrary.ProductItemType.KETTLE
        ];

        for (uint256 i = 0; i < productTypes.length; i++) {
            _updatePriceCache(productTypes[i]);
        }
    }

    function updateManufacturedProduct(
        ItemLibrary.ProductItemType _productType,
        uint256 _manufacturedPerQuarterDay
    ) external override onlyRole(ADMIN_ROLE) returns (bool) {
        require(
            _manufacturedProducts[_productType].manufacturedPerQuarterDay > 0,
            "Product does not exist"
        );
        _manufacturedProducts[_productType] = ManufacturedProduct(
            _manufacturedPerQuarterDay
        );
        return true;
    }

    function getProductEconomy(
        ItemLibrary.ProductItemType _productType
    ) external view override returns (ProductEconomy memory) {
        return _products[_productType];
    }

    function getManufacturedProduct(
        ItemLibrary.ProductItemType _productType
    ) external view override returns (ManufacturedProduct memory) {
        return _manufacturedProducts[_productType];
    }

    function updateActivityFee(
        CompanyAcitivityEnergyFeeType _activityType,
        uint256 _fee
    ) external override returns (bool) {}

    function getActivityFee(
        CompanyAcitivityEnergyFeeType _activityType
    ) external view override returns (ActivityEnergyFee memory) {
        return _activityFees[_activityType];
    }
}

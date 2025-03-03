// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICAFContractRegistry} from "../interfaces/ICAFContractRegistry.sol";
import {ICAFGameManger} from "../interfaces/ICAFGameManager.sol";
import {CAFToken} from "../../tokenomics/CAFToken.sol";
import {CAFAccessControl} from "./CAFAccessControl.sol";
import {IMaterialFactory} from "../interfaces/IMaterialFactory.sol";
import {ItemLibrary} from "../libraries/ItemLibrary.sol";

contract CAFGameManager is ICAFGameManger, CAFAccessControl {
    /*
    ============================ 🌍 GAME STORY: GAME Manager ============================
    - The game manager is the core of the game, it will manage all the game logic and rules
    */

    bool private _isInitialized;

    CAFToken private _cafToken;
    IMaterialFactory private _materialFactory;

    constructor(
        address _contractRegistry
    ) CAFAccessControl(_contractRegistry) {}

    function init() external {
        require(!_isInitialized, "CAFGameManager: already initialized");

        _cafToken = CAFToken(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry.ContractRegistryType.CAF_TOKEN_CONTRACT
                )
            )
        );

        _materialFactory = IMaterialFactory(
            registry.getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_MATERIAL_FACTORY_CONTRACT
                )
            )
        );

        _isInitialized = true;
    }

    function autoTriggerPerHour() external override {
        _materialFactory.manufactureProduct(
            ItemLibrary.ProductItemType.POWDERED_MILK
        );
        _materialFactory.manufactureProduct(ItemLibrary.ProductItemType.WATER);
        _materialFactory.manufactureProduct(
            ItemLibrary.ProductItemType.MACHINE_MATERIAL
        );
        _materialFactory.manufactureProduct(ItemLibrary.ProductItemType.KETTLE);
        _materialFactory.manufactureProduct(
            ItemLibrary.ProductItemType.MILK_FROTHER
        );
    }

    function transferToken(
        address _to,
        uint256 _amount
    ) external override onlyRole(SYSTEM_ROLE) {
        _cafToken.transfer(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ICAFProductItems.sol";
import "../dependency/ICAFContractRegistry.sol";
import "../libraries/ItemLibrary.sol";
import "../items/CAFCompanyItems.sol";
import "../items/CAFItems.sol";

contract CAFProductItems is ICAFProducts, ERC1155, CAFItems {
    // ======================== PRODUCT ITEMS TYPE ===================================
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

    // ============================== STATES =========================================
    address public immutable companyItemsAddress;

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    constructor(
        address _contractRegistry
    )
        CAFItems(_contractRegistry)
        ERC1155("https://game.example/api/item/{id}.json")
    {
        companyItemsAddress = ICAFContractRegistry(_contractRegistry)
            .getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            );

        uint8 initialSupply = 0;

        _mint(
            msg.sender,
            uint256(ProductItemType.BLACK_COFFEE),
            initialSupply,
            ""
        );
        _mint(
            msg.sender,
            uint256(ProductItemType.SUGAR_COFFEE),
            initialSupply,
            ""
        );
        _mint(msg.sender, uint256(ProductItemType.ESPRESSO), initialSupply, "");
        _mint(
            msg.sender,
            uint256(ProductItemType.MILK_COFFEE),
            initialSupply,
            ""
        );

        _mint(
            msg.sender,
            uint256(ProductItemType.COFFEE_BEAN),
            initialSupply,
            ""
        );
        _mint(msg.sender, uint256(ProductItemType.MILK), initialSupply, "");
        _mint(msg.sender, uint256(ProductItemType.SUGAR), initialSupply, "");
        _mint(msg.sender, uint256(ProductItemType.WATER), initialSupply, "");

        _mint(msg.sender, uint256(ProductItemType.GRINDER), initialSupply, "");
        _mint(msg.sender, uint256(ProductItemType.KETTLE), initialSupply, "");
        _mint(msg.sender, uint256(ProductItemType.MOKA_POT), initialSupply, "");
        _mint(
            msg.sender,
            uint256(ProductItemType.MILK_FROTHER),
            initialSupply,
            ""
        );
    }

    function create(
        address _owner,
        uint256 _type,
        string memory _uri
    ) external override returns (uint256) {
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

        uint256 id = uint256(_type);
        _mint(_owner, id, 1, "");

        return id;
    }

    function remove(uint256 _id) external override {}

}

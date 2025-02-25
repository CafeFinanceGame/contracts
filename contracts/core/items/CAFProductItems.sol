// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interfaces/ICAFProductItems.sol";
import "../dependency/ICAFContractRegistry.sol";
import "../libraries/ItemLibrary.sol";
import "../items/CAFCompanyItems.sol";
import "../items/CAFItems.sol";

contract CAFProductItems is ICAFProducts, ERC1155, CAFItems {
    // ======================== PRODUCT ITEMS TYPE ===================================

    // Coffee Company
    uint256 public constant BLACK_COFFEE = uint256(keccak256("BLACK_COFFEE"));
    uint256 public constant SUGAR_COFFEE = uint256(keccak256("SUGAR_COFFEE"));
    uint256 public constant ESPRESSO = uint256(keccak256("ESPRESSO"));
    uint256 public constant MILK_COFFEE = uint256(keccak256("MILK_COFFEE"));

    // Material Company
    uint256 public constant COFFEE_BEAN = uint256(keccak256("COFFEE_BEAN"));
    uint256 public constant MILK = uint256(keccak256("MILK"));
    uint256 public constant SUGAR = uint256(keccak256("SUGAR"));
    uint256 public constant WATER = uint256(keccak256("WATER"));

    // Machine Company
    uint256 public constant GRINDER = uint256(keccak256("GRINDER"));
    uint256 public constant KETTLE = uint256(keccak256("KETTLE"));
    uint256 public constant MOKA_POT = uint256(keccak256("MOKA_POT"));
    uint256 public constant MILK_FROTHER = uint256(keccak256("MILK_FROTHER"));

    // ============================== STATES =========================================
    address public companyItemsAddress;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        companyItemsAddress = ICAFContractRegistry(msg.sender)
            .getContractAddress(
                uint256(
                    ICAFContractRegistry
                        .ContractRegistryType
                        .CAF_COMPANY_ITEMS_CONTRACT
                )
            );

        uint8 initialSupply = 0;

        _mint(msg.sender, BLACK_COFFEE, initialSupply, "");
        _mint(msg.sender, SUGAR_COFFEE, initialSupply, "");
        _mint(msg.sender, ESPRESSO, initialSupply, "");
        _mint(msg.sender, MILK_COFFEE, initialSupply, "");

        _mint(msg.sender, COFFEE_BEAN, initialSupply, "");
        _mint(msg.sender, MILK, initialSupply, "");
        _mint(msg.sender, SUGAR, initialSupply, "");
        _mint(msg.sender, WATER, initialSupply, "");

        _mint(msg.sender, GRINDER, initialSupply, "");
        _mint(msg.sender, KETTLE, initialSupply, "");
        _mint(msg.sender, MOKA_POT, initialSupply, "");
        _mint(msg.sender, MILK_FROTHER, initialSupply, "");
    }

    function create(
        address _owner,
        uint256 _type
    ) external override returns (uint128) {
        require(
            _type == keccak256("BLACK_COFFEE") ||
                _type == keccak256("SUGAR_COFFEE") ||
                _type == keccak256("ESPRESSO") ||
                _type == keccak256("MILK_COFFEE") ||
                _type == keccak256("COFFEE_BEAN") ||
                _type == keccak256("MILK") ||
                _type == keccak256("SUGAR") ||
                _type == keccak256("WATER") ||
                _type == keccak256("GRINDER") ||
                _type == keccak256("KETTLE") ||
                _type == keccak256("MOKA_POT") ||
                _type == keccak256("MILK_FROTHER"),
            "ProductItems: invalid type"
        );

        require(
            CAFCompanyItems(companyItemsAddress).isCompany(_owner),
            "ProductItems: owner not found"
        );

        uint128 id = uint128(_type);
        _mint(_owner, id, 1, "");

        return id;
    }

    function remove(uint128 _id) external override {}

    function isExist(uint128 _id) external view override returns (bool) {
        return balanceOf(msg.sender, _id) > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^.8 .2;

import "./interfaces/IERC1155Product.sol";

contract ProductItem is IERC1155Product {
    // ======================== PRODUCT ITEMS TYPE ===================================

    // Coffee Company
    uint256 public constant BLACK_COFFEE = uint256(keccak256("BLACK_COFFEE"));
    uint256 public constant BLACK_SUGAR_COFFEE =
        uint256(keccak256("BLACK_SUGAR_COFFEE"));
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

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        uint8 initialSupply = 0;

        _mint(msg.sender, BLACK_COFFEE, initialSupply, "");
        _mint(msg.sender, BLACK_SUGAR_COFFEE, initialSupply, "");
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

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {}

    function balanceOf(
        address account,
        uint256 id
    ) external view override returns (uint256) {}

    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view override returns (uint256[] memory) {}

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {}

    function isApprovedForAll(
        address account,
        address operator
    ) external view override returns (bool) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override {}
}

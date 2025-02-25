// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interfaces/ICAFProductItems.sol";
import "../libraries/ItemLibrary.sol";

contract CAFProductItems is ICAFProducts, ERC1155 {
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

    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {}

    function ownerOf(
        uint256 tokenId
    ) external view override returns (address owner) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

    function approve(address to, uint256 tokenId) external override {}

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC1155, IERC721) {}

    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {}

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(ERC1155, IERC721) returns (bool) {}

    function create(
        address _owner,
        bytes32 _type
    ) external override returns (uint256) {}

    function remove(uint256 _id) external override {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IItem.sol";

contract Item is IItem {
    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {}

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
    ) external override {}

    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {}

    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {}

    function name() external view override returns (string memory) {}

    function symbol() external view override returns (string memory) {}

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFMarketplace {
    struct ListedItem {
        uint256 id;
        address owner;
        uint256 price;
    }

    // ==================== ACTIONS ====================

    /// @notice Buy the item
    /// @param _itemId The id of the item
    function buy(uint256 _itemId) external;

    /// @notice List the item
    /// @param _itemId The id of the item
    /// @param _price The price of the item
    function list(uint256 _itemId, uint256 _price) external;

    /// @notice Unlist the item
    /// @param _itemId The id of the item
    /// @dev The item will be unlisted from the marketplace
    function unlist(uint256 _itemId) external;

    /// @notice Update the price of the item
    /// @param _itemId The id of the item
    /// @param _price The price of the item
    function updatePrice(uint256 _itemId, uint256 _price) external;

    /// @notice Get all listed items
    /// @return All listed items
    function getAllListedItemIds() external view returns (uint256[] memory);

    /// @notice Get the listed item
    /// @param _itemId The id of the item
    function getListedItem(
        uint256 _itemId
    ) external view returns (ListedItem memory);

    /// @notice Get the last auto list time
    /// @return The last auto list time
    function getLastAutoListTime() external view returns (uint256);

    // @notice Auto list per hour
    function autoList() external;

    // ==================== EVENTS ====================

    event ItemListed(
        uint256 indexed _itemId,
        address indexed _owner,
        uint256 _price
    );
    event ItemUnlisted(uint256 indexed _itemId, address indexed _owner);
    event ItemBought(
        uint256 indexed _itemId,
        address indexed _buyer,
        address indexed _seller,
        uint256 _price
    );
    event ItemPriceUpdated(
        uint256 indexed _itemId,
        address indexed _owner,
        uint256 _price
    );
    event AllAutoListed(uint256 lastListed);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICAFContractRegistry {
    enum ContractRegistryType {
        CAF_TOKEN_CONTRACT,
        CAF_GAME_MANAGER_CONTRACT,
        CAF_MARKETPLACE_CONTRACT,
        CAF_GAME_ECONOMY_CONTRACT,
        CAF_ITEMS_MANAGER_CONTRACT
    }

    // ========================== ACTIONS ==========================
    function getContractAddress(
        uint256 contractType
    ) external view returns (address);

    function registerContract(
        uint256 contractType,
        address contractAddress
    ) external;

    function unregisterContract(uint256 contractType) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICAFContractRegistry {
    enum ContractRegistryType {
        CAF_MARKETPLACE_CONTRACT,
        CAF_POOL_CONTRACT,
        CAF_GAME_MANAGER_CONTRACT,
        CAF_GAME_ECONOMY_CONTRACT,
        CAF_COMPANY_ITEMS_CONTRACT,
        CAF_MATERIAL_ITEMS_CONTRACT,
        CAF_PRODUCT_ITEMS_CONTRACT,
        CAF_MACHINE_ITEMS_CONTRACT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFPoolFactory {
    // ========================== STATE ==========================
    function owner() external view returns (address);

    // ========================== ACTIONS ==========================
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function getPool(
        address tokenA,
        address tokenB
    ) external view returns (address pool);

    // ========================== EVENTS ==========================
    event PoolCreated(
        address indexed tokenA,
        address indexed tokenB,
        uint24 fee,
        address pool
    );
}

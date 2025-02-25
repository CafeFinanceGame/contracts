// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/ICAFPoolFactory.sol";
import "./CAFPool.sol";

contract CAFPoolFactory is ICAFPoolFactory {
    mapping(address => mapping(address => address)) public override getPool;

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external override returns (address pool) {
        require(tokenA != tokenB, "Identical tokens");
        require(getPool[tokenA][tokenB] == address(0), "Pool already exists");

        pool = address(new CAFPool(msg.sender));
        getPool[tokenA][tokenB] = pool;
        getPool[tokenB][tokenA] = pool;

        ICAFPool(pool).initialize(tokenA, tokenB);

        emit PoolCreated(tokenA, tokenB, fee, pool);
    }

    function owner() external view override returns (address) {}
}

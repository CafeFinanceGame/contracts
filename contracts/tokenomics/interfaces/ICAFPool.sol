// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICAFPool {
    // IMMUTABLES
    function factory() external view returns (address);

    function tokenA() external view returns (address);

    function tokenB() external view returns (address);

    function reserveA() external view returns (uint128);

    function reserveB() external view returns (uint128);

    function fee() external view returns (uint24);

    function liquidity(address) external view returns (uint128);

    // ACTIONS
    function initialize(address _tokenA, address _tokenB) external;

    function addLiquidity(
        uint128 amountA,
        uint128 amountB
    ) external returns (uint128);

    function removeLiquidity(
        uint128 liquidity
    ) external returns (uint128 amountA, uint128 amountB);

    function swap(
        uint128 amountIn,
        address tokenIn
    ) external returns (uint128 amountOut);

    // EVENTS
    event LiquidityAdded(
        address indexed provider,
        uint128 amountA,
        uint128 amountB,
        uint128 liquidity
    );

    event LiquidityRemoved(
        address indexed provider,
        uint128 amountA,
        uint128 amountB,
        uint128 liquidity
    );
    event Swap(
        address indexed trader,
        uint128 amountIn,
        address tokenIn,
        uint128 amountOut
    );
}

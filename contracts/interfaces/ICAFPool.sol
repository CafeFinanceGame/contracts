// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICAFPool {
    // IMMUTABLES
    function factory() external view returns (address);

    function tokenA() external view returns (address);

    function tokenB() external view returns (address);

    function reserveA() external view returns (uint256);

    function reserveB() external view returns (uint256);

    function fee() external view returns (uint24);

    function liquidity(address) external view returns (uint256);

    // ========================== ACTIONS ==========================
    function initialize(address _tokenA, address _tokenB) external;

    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external returns (uint256);

    function removeLiquidity(
        uint256 liquidity
    ) external returns (uint256 amountA, uint256 amountB);

    function swap(
        uint256 amountIn,
        address tokenIn
    ) external returns (uint256 amountOut);

    // ========================== EVENTS ==========================
    event LiquidityAdded(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    event LiquidityRemoved(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    event Swap(
        address indexed trader,
        uint256 amountIn,
        address tokenIn,
        uint256 amountOut
    );
}

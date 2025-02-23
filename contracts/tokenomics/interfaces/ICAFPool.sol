// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

interface ICAFPool {
    // IMMUTABLES
    function factory() external view returns (address);
    function tokenA() external view returns (address);
    function tokenB() external view returns (address);
    function minTokenAToSwap() external view returns (uint256);
    function minTokenBToSwap() external view returns (uint256);
    function maxTokenAToSwap() external view returns (uint256);
    function maxTokenBToSwap() external view returns (uint256);
    function fee() external view returns (uint256);

    // ACTIONS
    function initialize(address _tokenA, address _tokenB) external;
    function addLiquidity(uint256 amountA, uint256 amountB) external returns (uint256 liquidity);
    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB);
    function swap(uint256 amountIn, address tokenIn, address tokenOut) external returns (uint256 amountOut);

    // EVENTS
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 liquidity, uint256 amountA, uint256 amountB);
    event Swap(address indexed trader, uint256 amountIn, address tokenIn, address tokenOut, uint256 amountOut);

    // STATE
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB);
    function getTokenA() external view returns (address);
    function getTokenB() external view returns (address);
}
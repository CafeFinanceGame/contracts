// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./interfaces/ICAFPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CAFPool is ICAFPool {
    /// @inheritdoc ICAFPool
    address public immutable override factory;
    /// @inheritdoc ICAFPool
    address public override tokenA;
    /// @inheritdoc ICAFPool
    address public override tokenB;
    /// @inheritdoc ICAFPool
    uint256 public override reserveA;
    /// @inheritdoc ICAFPool
    uint256 public override reserveB;
    /// @inheritdoc ICAFPool
    uint24 public immutable override fee;
    /// @inheritdoc ICAFPool
    mapping(address => uint256) public override liquidity;

    constructor(address _factory) {
        factory = _factory;
    }

    function initialize(address _tokenA, address _tokenB) external override {
        require(
            tokenA == address(0) && tokenB == address(0),
            "Already initialized"
        );
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external override returns (uint256 mintedLiquidity) {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        reserveA += amountA;
        reserveB += amountB;

        mintedLiquidity = amountA * amountB;
        liquidity[msg.sender] += mintedLiquidity;

        emit LiquidityAdded(msg.sender, amountA, amountB, mintedLiquidity);
    }

    function removeLiquidity(
        uint256 _liquidity
    ) external override returns (uint256 amountA, uint256 amountB) {
        require(liquidity[msg.sender] >= _liquidity, "Not enough liquidity");

        amountA = (_liquidity * reserveA) / liquidity[msg.sender];
        amountB = (_liquidity * reserveB) / liquidity[msg.sender];

        reserveA -= amountA;
        reserveB -= amountB;
        liquidity[msg.sender] -= _liquidity;

        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, _liquidity, amountA, amountB);
    }

    function swap(
        uint256 amountIn,
        address tokenIn
    ) external override returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid amount");
        require(tokenIn == tokenA || tokenIn == tokenB, "Invalid token");

        address tokenOut = (tokenIn == tokenA) ? tokenB : tokenA;
        uint256 reserveIn = (tokenIn == tokenA) ? reserveA : reserveB;
        uint256 reserveOut = (tokenOut == tokenA) ? reserveA : reserveB;

        uint256 amountInWithFee = (amountIn * (10000 - fee)) / 10000;
        amountOut =
            (amountInWithFee * reserveOut) /
            (reserveIn + amountInWithFee);

        require(amountOut > 0, "Insufficient output amount");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        if (tokenIn == tokenA) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }

        emit Swap(msg.sender, amountIn, tokenIn, amountOut);
    }
}

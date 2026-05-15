// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LPToken.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract AMM {
    using SafeERC20 for IERC20;

    IERC20 public token0;
    IERC20 public token1;

    LPToken public lpToken;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE = 3; // 0.3%

    error InvalidAmount();
    error InsufficientLiquidity();

    event LiquidityAdded(
        address indexed user,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        lpToken = new LPToken();
    }

    function addLiquidity(
        uint256 amount0,
        uint256 amount1
    ) external returns (uint256 liquidity) {
        if (amount0 == 0 || amount1 == 0) {
            revert InvalidAmount();
        }

        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        liquidity = amount0 + amount1;

        lpToken.mint(msg.sender, liquidity);

        reserve0 += amount0;
        reserve1 += amount1;

        emit LiquidityAdded(
            msg.sender,
            amount0,
            amount1,
            liquidity
        );
    }
    
    function removeLiquidity(uint256 liquidity) 
    external returns (uint256 amount0, uint256 amount1) {

    if (liquidity == 0) {
        revert InvalidAmount();
    }

    uint256 totalSupply = lpToken.totalSupply();

    amount0 = (liquidity * reserve0) / totalSupply;
    amount1 = (liquidity * reserve1) / totalSupply;

    if (amount0 == 0 || amount1 == 0) {
        revert InsufficientLiquidity();
    }

    lpToken.burn(msg.sender, liquidity);

    reserve0 -= amount0;
    reserve1 -= amount1;

    token0.safeTransfer(msg.sender, amount0);
    token1.safeTransfer(msg.sender, amount1);
    }
}
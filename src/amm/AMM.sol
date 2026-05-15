// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LPToken.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract AMM is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    LPToken public immutable lpToken;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE_DENOMINATOR = 1000;
    uint256 public constant FEE_NUMERATOR = 997;

    error InvalidAmount();
    error InvalidToken();
    error InsufficientLiquidity();
    error SlippageExceeded();

    event LiquidityAdded(address indexed user, uint256 amount0, uint256 amount1, uint256 liquidity);

    event LiquidityRemoved(address indexed user, uint256 amount0, uint256 amount1, uint256 liquidity);

    event Swapped(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        lpToken = new LPToken();
    }

    function addLiquidity(uint256 amount0, uint256 amount1, uint256 minLiquidity)
        external
        nonReentrant
        returns (uint256 liquidity)
    {
        if (amount0 == 0 || amount1 == 0) {
            revert InvalidAmount();
        }

        token0.safeTransferFrom(msg.sender, address(this), amount0);

        token1.safeTransferFrom(msg.sender, address(this), amount1);

        if (lpToken.totalSupply() == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min((amount0 * lpToken.totalSupply()) / reserve0, (amount1 * lpToken.totalSupply()) / reserve1);
        }

        if (liquidity < minLiquidity) {
            revert SlippageExceeded();
        }

        if (liquidity == 0) {
            revert InsufficientLiquidity();
        }

        lpToken.mint(msg.sender, liquidity);

        reserve0 += amount0;
        reserve1 += amount1;

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    function removeLiquidity(uint256 liquidity, uint256 minAmount0, uint256 minAmount1)
        external
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        if (liquidity == 0) {
            revert InvalidAmount();
        }

        uint256 totalSupply = lpToken.totalSupply();

        amount0 = (liquidity * reserve0) / totalSupply;

        amount1 = (liquidity * reserve1) / totalSupply;

        if (amount0 < minAmount0 || amount1 < minAmount1) {
            revert SlippageExceeded();
        }

        lpToken.burn(msg.sender, liquidity);

        reserve0 -= amount0;
        reserve1 -= amount1;

        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        returns (uint256 amountOut)
    {
        if (amountIn == 0) {
            revert InvalidAmount();
        }

        if (reserveIn == 0 || reserveOut == 0) {
            revert InsufficientLiquidity();
        }

        uint256 amountInWithFee = amountIn * FEE_NUMERATOR;

        uint256 numerator = amountInWithFee * reserveOut;

        uint256 denominator = (reserveIn * FEE_DENOMINATOR) + amountInWithFee;

        amountOut = numerator / denominator;
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        if (amountIn == 0) {
            revert InvalidAmount();
        }

        bool isToken0 = tokenIn == address(token0);

        if (tokenIn != address(token0) && tokenIn != address(token1)) {
            revert InvalidToken();
        }

        (IERC20 inputToken, IERC20 outputToken, uint256 reserveIn, uint256 reserveOut) =
            isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        inputToken.safeTransferFrom(msg.sender, address(this), amountIn);

        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);

        if (amountOut < minAmountOut) {
            revert SlippageExceeded();
        }

        outputToken.safeTransfer(msg.sender, amountOut);

        if (isToken0) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }

        emit Swapped(msg.sender, tokenIn, amountIn, amountOut);
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;

            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

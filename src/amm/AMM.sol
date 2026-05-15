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

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        lpToken = new LPToken();
    }
}
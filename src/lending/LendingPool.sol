// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LendingPool is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable collateralToken;
    IERC20 public immutable borrowToken;

    uint256 public constant LTV = 75;
    uint256 public constant LIQUIDATION_THRESHOLD = 80;
    uint256 public constant PRECISION = 100;

    mapping(address => uint256) public collateralBalance;

    mapping(address => uint256) public borrowedAmount;

    error InvalidAmount();
    error InsufficientCollateral();
    error HealthFactorTooLow();
    error NoDebt();
    error PositionHealthy();

    event CollateralDeposited(address indexed user, uint256 amount);

    event Borrowed(address indexed user, uint256 amount);

    event Repaid(address indexed user, uint256 amount);

    event CollateralWithdrawn(address indexed user, uint256 amount);

    event Liquidated(
        address indexed user, address indexed liquidator, uint256 repaidDebt
    );

    constructor(
        address _collateralToken,
        address _borrowToken
    ) {
        collateralToken = IERC20(_collateralToken);

        borrowToken = IERC20(_borrowToken);
    }

    function depositCollateral(
        uint256 amount
    ) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }

        collateralToken.safeTransferFrom(msg.sender, address(this), amount);

        collateralBalance[msg.sender] += amount;

        emit CollateralDeposited(msg.sender, amount);
    }

    function borrow(
        uint256 amount
    ) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }

        uint256 maxBorrow = (collateralBalance[msg.sender] * LTV) / PRECISION;

        if (borrowedAmount[msg.sender] + amount > maxBorrow) {
            revert InsufficientCollateral();
        }

        borrowedAmount[msg.sender] += amount;

        borrowToken.safeTransfer(msg.sender, amount);

        emit Borrowed(msg.sender, amount);
    }

    function repay(
        uint256 amount
    ) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }

        if (borrowedAmount[msg.sender] == 0) {
            revert NoDebt();
        }

        borrowToken.safeTransferFrom(msg.sender, address(this), amount);

        borrowedAmount[msg.sender] -= amount;

        emit Repaid(msg.sender, amount);
    }

    function withdrawCollateral(
        uint256 amount
    ) external nonReentrant {
        if (amount == 0) {
            revert InvalidAmount();
        }

        if (collateralBalance[msg.sender] < amount) {
            revert InsufficientCollateral();
        }

        collateralBalance[msg.sender] -= amount;

        uint256 healthFactor = getHealthFactor(msg.sender);

        if (
            borrowedAmount[msg.sender] > 0
                && healthFactor < LIQUIDATION_THRESHOLD
        ) {
            revert HealthFactorTooLow();
        }

        collateralToken.safeTransfer(msg.sender, amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function liquidate(
        address user
    ) external nonReentrant {
        if (borrowedAmount[user] == 0) {
            revert NoDebt();
        }

        uint256 healthFactor = getHealthFactor(user);

        if (healthFactor >= LIQUIDATION_THRESHOLD) {
            revert PositionHealthy();
        }

        uint256 debt = borrowedAmount[user];

        borrowToken.safeTransferFrom(msg.sender, address(this), debt);

        borrowedAmount[user] = 0;

        uint256 collateral = collateralBalance[user];

        collateralBalance[user] = 0;

        collateralToken.safeTransfer(msg.sender, collateral);

        emit Liquidated(user, msg.sender, debt);
    }

    function getHealthFactor(
        address user
    ) public view returns (uint256) {
        uint256 debt = borrowedAmount[user];

        if (debt == 0) {
            return type(uint256).max;
        }

        return (collateralBalance[user] * PRECISION) / debt;
    }
}

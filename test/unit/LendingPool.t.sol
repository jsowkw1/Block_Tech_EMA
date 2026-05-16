// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/lending/LendingPool.sol";
import "../../src/mocks/MockERC20.sol";

contract LendingPoolTest is Test {
    LendingPool pool;

    MockERC20 collateralToken;
    MockERC20 borrowToken;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        collateralToken = new MockERC20("Collateral", "COL");

        borrowToken = new MockERC20("Borrow", "BRW");

        pool = new LendingPool(address(collateralToken), address(borrowToken));

        collateralToken.mint(alice, 1_000e18);

        borrowToken.mint(address(pool), 1_000e18);
    }

    function test_DepositCollateral() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        vm.stopPrank();

        assertEq(pool.collateralBalance(alice), 100e18);
    }

    function test_Borrow() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.borrow(50e18);

        vm.stopPrank();

        assertEq(pool.borrowedAmount(alice), 50e18);
    }

    function test_Repay() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.borrow(50e18);

        borrowToken.approve(address(pool), 50e18);

        pool.repay(50e18);

        vm.stopPrank();

        assertEq(pool.borrowedAmount(alice), 0);
    }

    function test_WithdrawCollateral() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.withdrawCollateral(50e18);

        vm.stopPrank();

        assertEq(pool.collateralBalance(alice), 50e18);
    }

    function test_RevertBorrowTooMuch() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        vm.expectRevert(LendingPool.InsufficientCollateral.selector);

        pool.borrow(100e18);

        vm.stopPrank();
    }

    function test_HealthFactor() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.borrow(50e18);

        vm.stopPrank();

        uint256 hf = pool.getHealthFactor(alice);

        assertEq(hf, 200);
    }

    function test_Liquidation() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.borrow(75e18);

        vm.store(
            address(pool),
            keccak256(abi.encode(alice, uint256(0))),
            bytes32(uint256(10e18))
        );

        vm.stopPrank();

        borrowToken.mint(bob, 75e18);

        vm.startPrank(bob);

        borrowToken.approve(address(pool), 75e18);

        pool.liquidate(alice);

        vm.stopPrank();

        assertEq(pool.borrowedAmount(alice), 0);
    }

    function test_RevertLiquidationHealthyPosition() public {
        vm.startPrank(alice);

        collateralToken.approve(address(pool), 100e18);

        pool.depositCollateral(100e18);

        pool.borrow(40e18);

        vm.stopPrank();

        borrowToken.mint(bob, 40e18);

        vm.startPrank(bob);

        borrowToken.approve(address(pool), 40e18);

        vm.expectRevert(LendingPool.PositionHealthy.selector);

        pool.liquidate(alice);

        vm.stopPrank();
    }

    function test_RevertLiquidationNoDebt() public {
        vm.expectRevert(LendingPool.NoDebt.selector);

        pool.liquidate(alice);
    }
}

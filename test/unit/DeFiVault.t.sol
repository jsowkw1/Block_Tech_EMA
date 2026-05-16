// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/vault/DeFiVault.sol";
import "../../src/mocks/MockERC20.sol";

contract DeFiVaultTest is Test {
    DeFiVault vault;

    MockERC20 asset;

    address alice = address(1);

    address bob = address(2);

    function setUp() public {
        asset = new MockERC20("Mock USDC", "mUSDC");

        vault = new DeFiVault(asset, address(this));

        asset.mint(alice, 1000e18);

        asset.mint(bob, 1000e18);
    }

    function test_Deposit() public {
        vm.startPrank(alice);

        asset.approve(address(vault), 100e18);

        vault.deposit(100e18, alice);

        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 100e18);

        assertEq(vault.totalAssets(), 100e18);
    }

    function test_Withdraw() public {
        vm.startPrank(alice);

        asset.approve(address(vault), 100e18);

        vault.deposit(100e18, alice);

        vault.withdraw(50e18, alice, alice);

        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 50e18);
    }

    function test_MintShares() public {
        vm.startPrank(alice);

        asset.approve(address(vault), 200e18);

        vault.mint(100e18, alice);

        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 100e18);
    }

    function test_RedeemShares() public {
        vm.startPrank(alice);

        asset.approve(address(vault), 100e18);

        vault.deposit(100e18, alice);

        vault.redeem(40e18, alice, alice);

        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 60e18);
    }

    function test_RevertDepositZero() public {
        vm.startPrank(alice);

        vm.expectRevert(DeFiVault.InvalidAmount.selector);

        vault.deposit(0, alice);

        vm.stopPrank();
    }

    function test_RevertWithdrawZero() public {
        vm.startPrank(alice);

        vm.expectRevert(DeFiVault.InvalidAmount.selector);

        vault.withdraw(0, alice, alice);

        vm.stopPrank();
    }
}

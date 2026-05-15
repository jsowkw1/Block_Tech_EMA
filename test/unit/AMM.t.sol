// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/amm/AMM.sol";
import "../../src/mocks/MockERC20.sol";

contract AMMTest is Test {
    AMM public amm;

    MockERC20 public token0;
    MockERC20 public token1;

    address public user = address(1);

    function setUp() public {
        token0 = new MockERC20("Token0", "TK0");

        token1 = new MockERC20("Token1", "TK1");

        amm = new AMM(address(token0), address(token1));

        token0.mint(user, 1_000_000 ether);
        token1.mint(user, 1_000_000 ether);

        vm.startPrank(user);

        token0.approve(address(amm), type(uint256).max);

        token1.approve(address(amm), type(uint256).max);

        vm.stopPrank();
    }

    function testAddLiquidity() public {
        vm.startPrank(user);

        amm.addLiquidity(100 ether, 100 ether, 100 ether);

        vm.stopPrank();

        assertEq(amm.reserve0(), 100 ether);

        assertEq(amm.reserve1(), 100 ether);
    }

    function testSwap() public {
        vm.startPrank(user);

        amm.addLiquidity(100 ether, 100 ether, 100 ether);

        amm.swap(address(token0), 10 ether, 1 ether);

        vm.stopPrank();

        assertGt(token1.balanceOf(user), 999900 ether);
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);

        amm.addLiquidity(100 ether, 100 ether, 100 ether);

        uint256 lpBalance = amm.lpToken().balanceOf(user);

        amm.removeLiquidity(lpBalance, 1 ether, 1 ether);

        vm.stopPrank();

        assertEq(amm.reserve0(), 0);

        assertEq(amm.reserve1(), 0);
    }
}

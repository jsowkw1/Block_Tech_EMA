// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/amm/AMM.sol";
import "../../src/mocks/MockERC20.sol";

contract AMMFuzzTest is Test {
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

    function testFuzz_AddLiquidity(
        uint96 amount0,
        uint96 amount1
    ) public {
        amount0 = uint96(bound(amount0, 1 ether, 1000 ether));

        amount1 = uint96(bound(amount1, 1 ether, 1000 ether));

        vm.startPrank(user);

        amm.addLiquidity(amount0, amount1, 1);

        vm.stopPrank();

        assertEq(amm.reserve0(), amount0);

        assertEq(amm.reserve1(), amount1);
    }

    function testFuzz_Swap(
        uint96 liquidity,
        uint96 swapAmount
    ) public {
        liquidity = uint96(bound(liquidity, 100 ether, 1000 ether));

        swapAmount = uint96(bound(swapAmount, 1 ether, 100 ether));

        vm.startPrank(user);

        amm.addLiquidity(liquidity, liquidity, 1);

        amm.swap(address(token0), swapAmount, 1);

        vm.stopPrank();

        assertGt(amm.reserve0(), liquidity);
    }
}

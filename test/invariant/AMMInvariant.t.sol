// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import "../../src/amm/AMM.sol";
import "../../src/mocks/MockERC20.sol";

contract AMMInvariantTest is StdInvariant, Test {
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

        amm.addLiquidity(1000 ether, 1000 ether, 1000 ether);

        vm.stopPrank();

        targetContract(address(amm));
    }

    function invariant_KNeverZero() public view {
        uint256 k = amm.reserve0() * amm.reserve1();

        assertGt(k, 0);
    }
}

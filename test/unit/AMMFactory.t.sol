// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/amm/AMMFactory.sol";
import "../../src/mocks/MockERC20.sol";

contract AMMFactoryTest is Test {
    AMMFactory public factory;

    MockERC20 public token0;
    MockERC20 public token1;
    MockERC20 public token2;

    function setUp() public {
        factory = new AMMFactory();

        token0 = new MockERC20("Token0", "TK0");

        token1 = new MockERC20("Token1", "TK1");

        token2 = new MockERC20("Token2", "TK2");
    }

    function testCreatePool() public {
        address pool = factory.createPool(address(token0), address(token1));

        assertTrue(pool != address(0));

        assertEq(factory.getPool(address(token0), address(token1)), pool);
    }

    function testCannotCreateDuplicatePool() public {
        factory.createPool(address(token0), address(token1));

        vm.expectRevert();

        factory.createPool(address(token0), address(token1));
    }

    function testAllPoolsLength() public {
        factory.createPool(address(token0), address(token1));

        factory.createPool(address(token0), address(token2));

        assertEq(factory.allPoolsLength(), 2);
    }

    function testPoolAddressesDiffer() public {
        address pool1 = factory.createPool(address(token0), address(token1));

        address pool2 = factory.createPool(address(token0), address(token2));

        assertTrue(pool1 != pool2);
    }
}

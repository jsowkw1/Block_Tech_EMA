// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/governance/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken token;

    address owner = address(this);
    address alice = address(2);
    address bob = address(3);

    function setUp() public {
        vm.prank(owner);

        token = new GovernanceToken();
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), 1_000_000e18);
    }

    function test_OwnerHasAllTokens() public view {
        assertEq(token.balanceOf(owner), 1_000_000e18);
    }

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "DeFi Gov Token");

        assertEq(token.symbol(), "DGT");
    }

    function test_OwnerIsCorrect() public view {
        assertEq(token.owner(), owner);
    }

    function test_OwnerCanMint() public {
        vm.prank(owner);

        token.mint(alice, 500e18);

        assertEq(token.balanceOf(alice), 500e18);
    }

    function test_MintIncreasesTotalSupply() public {
        vm.prank(owner);

        token.mint(alice, 100e18);

        assertEq(token.totalSupply(), 1_000_100e18);
    }

    function test_RevertMint_NotOwner() public {
        vm.prank(alice);

        vm.expectRevert();

        token.mint(alice, 100e18);
    }

    function test_Transfer() public {
        vm.prank(owner);

        bool success = token.transfer(alice, 100e18);

        assertTrue(success);

        assertEq(token.balanceOf(alice), 100e18);
    }

    function test_RevertTransfer_InsufficientBalance() public {
        vm.prank(alice);

        vm.expectRevert();

        (bool success,) = address(token)
            .call(
                abi.encodeWithSignature("transfer(address,uint256)", bob, 1e18)
            );

        success;
    }

    function test_DelegateToSelf() public {
        vm.startPrank(owner);

        token.delegate(owner);

        assertEq(token.getVotes(owner), 1_000_000e18);

        vm.stopPrank();
    }

    function test_DelegateToAlice() public {
        vm.prank(owner);

        bool success = token.transfer(alice, 200e18);

        assertTrue(success);

        vm.prank(alice);

        token.delegate(alice);

        assertEq(token.getVotes(alice), 200e18);
    }

    function test_VotingPowerTransferAfterRedelegate() public {
        vm.prank(owner);

        bool success = token.transfer(alice, 300e18);

        assertTrue(success);

        vm.prank(alice);

        token.delegate(alice);

        assertEq(token.getVotes(alice), 300e18);

        vm.prank(alice);

        token.delegate(bob);

        assertEq(token.getVotes(alice), 0);

        assertEq(token.getVotes(bob), 300e18);
    }

    function test_NoVotingPowerWithoutDelegate() public view {
        assertEq(token.getVotes(owner), 0);
    }

    function test_PastVotesAfterTransfer() public {
        vm.startPrank(owner);

        token.delegate(owner);

        uint256 blockBefore = block.number;

        vm.roll(block.number + 1);

        bool success = token.transfer(alice, 100e18);

        assertTrue(success);

        vm.roll(block.number + 1);

        assertEq(token.getPastVotes(owner, blockBefore), 1_000_000e18);

        vm.stopPrank();
    }

    function test_PermitDomainSeparator() public view {
        bytes32 separator = token.DOMAIN_SEPARATOR();

        assertTrue(separator != bytes32(0));
    }

    function test_Nonce_StartsAtZero() public view {
        assertEq(token.nonces(alice), 0);
    }
}

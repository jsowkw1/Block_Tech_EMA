// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeFiVault is ERC4626, Ownable {
    error InvalidAmount();

    constructor(
        IERC20 asset_,
        address initialOwner
    ) ERC20("DeFi Vault Share", "DVS") ERC4626(asset_) Ownable(initialOwner) { }

    function deposit(
        uint256 assets,
        address receiver
    ) public override returns (uint256) {
        if (assets == 0) {
            revert InvalidAmount();
        }

        return super.deposit(assets, receiver);
    }

    function mint(
        uint256 shares,
        address receiver
    ) public override returns (uint256) {
        if (shares == 0) {
            revert InvalidAmount();
        }

        return super.mint(shares, receiver);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override returns (uint256) {
        if (assets == 0) {
            revert InvalidAmount();
        }

        return super.withdraw(assets, receiver, owner);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override returns (uint256) {
        if (shares == 0) {
            revert InvalidAmount();
        }

        return super.redeem(shares, receiver, owner);
    }
}

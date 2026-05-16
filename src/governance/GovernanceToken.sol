// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20Votes, Ownable {
    error InvalidAddress();
    error InvalidAmount();

    uint256 public constant MAX_SUPPLY = 10_000_000e18;

    constructor() ERC20("DeFi Gov Token", "DGT") ERC20Permit("DeFi Gov Token") {
        _mint(msg.sender, 1_000_000e18);
    }

    function mint(
        address to,
        uint256 amount
    ) external onlyOwner {
        if (to == address(0)) {
            revert InvalidAddress();
        }

        if (amount == 0) {
            revert InvalidAmount();
        }

        if (totalSupply() + amount > MAX_SUPPLY) {
            revert InvalidAmount();
        }

        _mint(to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._burn(account, amount);
    }
}

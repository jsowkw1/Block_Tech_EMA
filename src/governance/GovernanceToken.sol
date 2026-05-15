// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20Votes, ERC20Permit, Ownable {
    constructor(address initialOwner)
        ERC20("DeFi Gov Token", "DGT")
        ERC20Permit("DeFi Gov Token")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 1_000_000e18);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(address account) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(account);
    }
}

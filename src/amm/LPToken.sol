// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public amm;

    error NotAMM();

    constructor() ERC20("Liquidity Provider Token", "LPT") {
        amm = msg.sender;
    }

    modifier onlyAMM() {
        if (msg.sender != amm) revert NotAMM();
        _;
    }

    function mint(address to, uint256 amount) external onlyAMM {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyAMM {
        _burn(from, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AMM.sol";

contract AMMFactory {
    mapping(address => mapping(address => address)) public getPool;

    address[] public allPools;

    error IdenticalAddresses();
    error ZeroAddress();
    error PoolAlreadyExists();

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        address pool,
        uint256 totalPools
    );

    function createPool(
        address tokenA,
        address tokenB
    ) external returns (address pool) {
        if (tokenA == tokenB) {
            revert IdenticalAddresses();
        }

        if (tokenA == address(0) || tokenB == address(0)) {
            revert ZeroAddress();
        }

        (address token0, address token1) =
            tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        if (getPool[token0][token1] != address(0)) {
            revert PoolAlreadyExists();
        }

        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        pool = address(new AMM{ salt: salt }(token0, token1));

        getPool[token0][token1] = pool;
        getPool[token1][token0] = pool;

        allPools.push(pool);

        emit PoolCreated(token0, token1, pool, allPools.length);
    }

    function allPoolsLength() external view returns (uint256) {
        return allPools.length;
    }
}

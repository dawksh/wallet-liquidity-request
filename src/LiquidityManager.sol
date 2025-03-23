// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LiquidityManager {
    event LiquidityRequested(
        bytes32 indexed hash,
        uint256 amount,
        uint256 timestamp
    );

    function requestLiquidity(bytes32 hash, uint256 amount) public {
        uint256 timestamp = block.timestamp;
        emit LiquidityRequested(hash, amount, timestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract LiquidityRequestor {
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

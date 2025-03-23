// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ECDSA} from "solady/utils/ECDSA.sol";
import {EIP712} from "solady/utils/EIP712.sol";

/// @title LiquidityPool
/// @notice A contract for managing liquidity and executing secure transfers
/// @dev Uses EIP712 for typed data signing and verification
contract LiquidityPool is EIP712 {
    using ECDSA for bytes32;

    /// @notice The owner of the contract
    address public owner;

    /// @notice Mapping of address to nonce for replay protection
    /// @dev Incremented after each successful transfer
    mapping(address => uint256) public nonces;

    /// @notice Emitted when a transfer is successfully executed
    /// @param to The recipient of the transfer
    /// @param amount The amount transferred
    /// @param nonce The nonce used for the transfer
    event TransferExecuted(address indexed to, uint256 amount, uint256 nonce);

    /// @notice Error thrown when a non-owner tries to perform an owner-only action
    error NotOwner();

    /// @notice Error thrown when signature verification fails
    error InvalidSignature();

    /// @notice Error thrown when a transfer fails
    error TransferFailed();

    /// @notice Initializes the contract and sets the deployer as the owner
    constructor() EIP712() {
        owner = msg.sender;
    }

    /// @notice Restricts function access to the contract owner
    /// @dev Reverts with NotOwner if called by any account other than the owner
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Executes a transfer with signature verification
    /// @dev Verifies the signature, increments the nonce, and transfers the funds
    /// @param to The recipient address
    /// @param amount The amount to transfer
    /// @param nonce The current nonce for replay protection
    /// @param signature The EIP712 signature authorizing the transfer
    function executeTransfer(
        address to,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) public onlyOwner {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Transfer(address to,uint256 amount,uint256 nonce)"),
                to,
                amount,
                nonce
            )
        );

        bytes32 hash = _hashTypedData(structHash);
        address signer = ECDSA.recover(hash, signature);

        if (signer != owner || nonce != nonces[owner]++)
            revert InvalidSignature();

        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit TransferExecuted(to, amount, nonce);
    }

    /// @notice Returns the domain name and version for EIP712 typed data
    /// @dev Overrides the function from the EIP712 contract
    /// @return name The domain name
    /// @return version The domain version
    function _domainNameAndVersion()
        internal
        pure
        override
        returns (string memory name, string memory version)
    {
        return ("Kotaru", "1");
    }

    /// @notice Allows the contract to receive ETH
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library ControlLibrary {
    bytes32 public constant SYSTEM_ROLE = keccak256("SYSTEM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
}

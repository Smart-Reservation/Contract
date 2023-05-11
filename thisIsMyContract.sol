// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ThisIsMyContract {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
}
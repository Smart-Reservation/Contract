// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./thisIsMyContract.sol";

contract UserRegistration is Ownable {
    struct User {
        bytes32 hashedAddress;
        bool registered;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed user);

    // Function to register a user
    function register() external {
        require(!users[msg.sender].registered, "User already registered");

        bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
        users[msg.sender] = User(hashedAddress, true);

        emit UserRegistered(msg.sender);
    }


    // Function to get the hashed address information
    function getHashedInfo() external view returns (bytes32) {
        require(users[msg.sender].registered, "User not registered");
        return users[msg.sender].hashedAddress;
    }

}

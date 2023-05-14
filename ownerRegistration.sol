// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./userRegistration.sol";


contract OwnerRegistration is UserRegistration {
    // Structure definition for owner information
    struct Owner {
        bytes32 hashedInfo;    // Hashed value of owner information
        bool isOwner;          // Owner status
    }

    // Mapping between owner hash and Owner structure
    mapping(bytes32 => Owner) public owners;

    // Event for owner registration completion
    event OwnerRegistered(bytes32 indexed hashedInfo);

    // Function for registering an owner
    function registerOwner(string memory ownerInfo) external onlyOwner{
        // Check if the owner is already registered
        bytes32 hashedInfo = keccak256(abi.encodePacked(msg.sender, ownerInfo));
        require(!owners[hashedInfo].isOwner, "Owner is already registered.");

        // Check if the user is registered as a user first 
        require(users[msg.sender].registered, "User must be registered first.");

        // Store owner information in the mapping
        owners[hashedInfo] = Owner(hashedInfo, true);

        // Emit an event
        emit OwnerRegistered(hashedInfo);
    }

    // Function to check registration status of an owner
    function isRegisteredOwner(string memory ownerInfo) external view returns (bool) {
        bytes32 hashedInfo = keccak256(abi.encodePacked(msg.sender, ownerInfo));
        return owners[hashedInfo].isOwner;
    }

    mapping(address => uint256) public depositAmounts; // Reservation deposit amount
    mapping(address => address) public storeOwners; // Mapping between stores and owners

    function setStoreOwner(address _store, address _owner) public {
        storeOwners[_store] = _owner;
    }

    function setDepositAmount(address _store, uint256 _depositAmount) external {
        // Check if the caller is the owner of the store
        bytes32 hashedInfo = keccak256(abi.encodePacked(msg.sender));
        require(owners[hashedInfo].isOwner, "Only the owner can set the deposit amount.");

        depositAmounts[_store] = _depositAmount;
    }
}

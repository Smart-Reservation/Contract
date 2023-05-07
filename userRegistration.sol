// SPDX-License-Identifier: MIT
pragma solidity >=0.7.2 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract UserRegistration is Ownable {
    struct User {
        bytes32 hashedAddress;
        bool registered;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed user);

    // 사용자 등록 함수
    function register() external {
        require(!users[msg.sender].registered, "User already registered");

        bytes32 hashedAddress = keccak256(abi.encodePacked(msg.sender));
        users[msg.sender] = User(hashedAddress, true);

        emit UserRegistered(msg.sender);
    }


    // 해시화된 주소 정보 가져오기 함수
    function getHashedInfo() external view onlyOwner returns (bytes32) {
        require(users[msg.sender].registered, "User not registered");
        return users[msg.sender].hashedAddress;
    }

}
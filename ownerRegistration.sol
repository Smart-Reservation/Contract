// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.2 < 0.9.0;
import "./userRegistration.sol";


contract OwnerRegistration is UserRegistration {
    // 오너 정보 구조체 정의
    struct Owner {
        bytes32 hashedInfo;    // 오너 정보의 해시값
        bool isOwner;          // 오너 여부 
    }

    // 오너 해시값과 Owner 구조체 간의 매핑
    mapping(bytes32 => Owner) public owners;

    // 이벤트(오너 등록 완료)
    event OwnerRegistered(bytes32 indexed hashedInfo);

    // 오너 등록 함수
    function registerOwner(string memory ownerInfo) external onlyOwner {
        // 이미 등록된 오너인지 확인
        bytes32 hashedInfo = keccak256(abi.encodePacked(msg.sender, ownerInfo));
        require(!owners[hashedInfo].isOwner, "Owner is already registered.");

        // 사용자가 먼저 사용자로 등록되어 있는지 확인 --> 제거하면 사용자가 아니더라도 오너로의 등록을 가능하게함
        require(users[msg.sender].registered, "User must be registered first.");

        // 오너 정보를 매핑에 저장
        owners[hashedInfo] = Owner(hashedInfo, true);

        // 이벤트 발행
        emit OwnerRegistered(hashedInfo);
    }

    // 등록 여부 확인 함수
    function isRegisteredOwner(string memory ownerInfo) external view returns (bool) {
        bytes32 hashedInfo = keccak256(abi.encodePacked(msg.sender, ownerInfo));
        return owners[hashedInfo].isOwner;
    }
    //예약금 설정(오너)
    mapping(address => uint256) public depositAmounts;

    function setDepositAmount(uint256 _depositAmount) external {
        depositAmounts[msg.sender] = _depositAmount;
    }
 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 예약 생성 컨트랙트
contract CreateReservation {
    // 예약에 대한 정보를 담는 구조체
    struct Reservation {
        uint256 id; // 예약 ID
        uint256 depositAmount; // 예약금
        address payable user; // 예약한 유저의 주소
        address payable owner; // 가게 주인의 주소
        ReservationStatus status; // 예약 상태
    }

    // 예약 상태를 나타내는 열거형
    enum ReservationStatus { Pending, Confirmed, CancelledByUser, CancelledByOwner, NoShow }

    // 예약 ID를 키로 하여 예약 정보를 저장하는 매핑
    mapping(uint256 => Reservation) public reservations;

    // 예약 생성 이벤트
    event ReservationCreated(uint256 id, address user);

    // 예약 생성 함수
    function createReservation(uint256 _reservationId, address payable _owner, uint256 _depositAmount) external {
        // 기존에 동일한 ID로 예약이 존재하는지 확인
        require(reservations[_reservationId].user == address(0), "Reservation with this ID already exists.");

        // 새로운 예약 생성
        Reservation storage newReservation = reservations[_reservationId];
        newReservation.id = _reservationId;
        newReservation.depositAmount = _depositAmount;
        newReservation.user = payable(msg.sender);
        newReservation.owner = _owner;
        newReservation.status = ReservationStatus.Pending;

        // 예약 생성 이벤트 발생
        emit ReservationCreated(_reservationId, msg.sender);
    }
}

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

    // 다음 예약 ID
    uint256 public nextReservationId;

    // 예약 생성 이벤트
    event ReservationCreated(uint256 id, address user);

    // 예약 생성 함수
    function createReservation(address payable _owner, uint256 _depositAmount) external {
        // 새로운 예약 생성
        Reservation storage newReservation = reservations[nextReservationId];
        newReservation.id = nextReservationId;
        newReservation.depositAmount = _depositAmount;
        newReservation.user = payable(msg.sender);
        newReservation.owner = _owner;
        newReservation.status = ReservationStatus.Pending;

        // 예약 생성 이벤트 발생
        emit ReservationCreated(nextReservationId, msg.sender);

        // 다음 예약 ID 갱신
        nextReservationId++;
    }
        // 예약 상태 변경 함수
    function updateReservationStatus(uint256 reservationId, ReservationStatus newStatus) external {
        Reservation storage reservation = reservations[reservationId];

        // 변경하려는 사용자가 예약한 사용자 혹은 가게 주인인지 확인
        require(
            msg.sender == reservation.user || msg.sender == reservation.owner,
            "Only the user or the owner can update the reservation status."
        );

        // 새로운 상태가 유효한 상태인지 확인
        require(
            uint(newStatus) >= 0 && uint(newStatus) <= 4,
            "Invalid reservation status."
        );

        // 상태 업데이트
        reservation.status = newStatus;
    }
}
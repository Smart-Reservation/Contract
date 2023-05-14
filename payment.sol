// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./createReservation.sol";
import "./ownerRegistration.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Payment is CreateReservation, OwnerRegistration {

    using SafeMath for uint256;

    mapping(address => uint256) public reservationDeposits;
    event DepositReceived(address indexed user, uint256 amount);
    event DepositRefunded(address indexed user, uint256 amount);
    event DepositTransferred(address indexed user, address indexed owner, uint256 amount);



    //예약금 입금 함수
    function deposit(uint256 requiredDepositAmount) external payable {
        uint256 amount = msg.value;

        require(amount == requiredDepositAmount, "Deposit amount does not match the required deposit amount.");

        reservationDeposits[msg.sender] = reservationDeposits[msg.sender].add(amount);
        emit DepositReceived(msg.sender, amount);
    }


    //예약이 유효한지, 예약상태 확인 후 환불 조건 충족되는지 확인, 
    function refundReservation(uint256 reservationId) external {
        Reservation storage reservation = reservations[reservationId];

        // 예약 상태 확인
        require(
            reservation.status == ReservationStatus.CancelledByUser || reservation.status == ReservationStatus.NoShow || reservation.status == ReservationStatus.CancelledByOwner,
            "Reservation is not in a refundable state."
        );

        // 환불 대상 결정 (유저 취소 또는 노쇼 시 오너에게, 오너 취소 시 유저에게)
        address payable refundRecipient;
        if (reservation.status == ReservationStatus.CancelledByUser || reservation.status == ReservationStatus.NoShow) {
            refundRecipient = reservation.owner;
        } else if (reservation.status == ReservationStatus.CancelledByOwner) {
            refundRecipient = reservation.user;
        }

        // 환불 처리
        uint256 refundAmount = reservation.depositAmount;
        reservation.depositAmount = 0;
        refundRecipient.transfer(refundAmount);
    }


     // 예약 확인 후 예약금 반환
    function confirmReservation(uint256 reservationId) external {
        Reservation storage reservation = reservations[reservationId];

        // 예약 상태 확인
        require(
            reservation.status == ReservationStatus.Pending,
            "Reservation is not in a pending state."
        );

        // 예약 상태를 확정으로 변경
        reservation.status = ReservationStatus.Confirmed;

        // 예약금 반환 처리
        uint256 refundAmount = reservation.depositAmount;
        reservation.depositAmount = 0;
        reservation.user.transfer(refundAmount);
    }


}

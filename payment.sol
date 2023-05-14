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


    // Function for depositing reservation deposit amount
    function deposit(uint256 requiredDepositAmount) external payable {
        uint256 amount = msg.value;

        require(amount == requiredDepositAmount, "Deposit amount does not match the required deposit amount.");

        reservationDeposits[msg.sender] = reservationDeposits[msg.sender].add(amount);
        emit DepositReceived(msg.sender, amount);
    }

    // Function for refunding a reservation if it is valid and meets the refund conditions 
    function refundReservation(uint256 reservationId) external {
        Reservation storage reservation = reservations[reservationId];

        // Check reservation status
        require(
            reservation.status == ReservationStatus.CancelledByUser || reservation.status == ReservationStatus.NoShow || reservation.status == ReservationStatus.CancelledByOwner,
            "Reservation is not in a refundable state."
        );

        // Determine the refund recipient (to the owner if cancelled by the user or no-show, to the user if cancelled by the owner)
        address payable refundRecipient;
        if (reservation.status == ReservationStatus.CancelledByUser || reservation.status == ReservationStatus.NoShow) {
            refundRecipient = reservation.owner;
        } else if (reservation.status == ReservationStatus.CancelledByOwner) {
            refundRecipient = reservation.user;
        }

        // Process the refund
        uint256 refundAmount = reservation.depositAmount;
        reservation.depositAmount = 0;
        refundRecipient.transfer(refundAmount);
    }


     // Function for confirming a reservation and returning the deposit amount
    function confirmReservation(uint256 reservationId) external {
        Reservation storage reservation = reservations[reservationId];

        // Check reservation status
        require(
            reservation.status == ReservationStatus.Pending,
            "Reservation is not in a pending state."
        );

        // Change reservation status to confirmed
        reservation.status = ReservationStatus.Confirmed;

        // Return the deposit amount
        uint256 refundAmount = reservation.depositAmount;
        reservation.depositAmount = 0;
        reservation.user.transfer(refundAmount);
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Reservation Creation Contract
contract CreateReservation {
    // Structure to hold reservation information
    struct Reservation {
        uint256 id; // Reservation ID
        uint256 depositAmount; // Reservation deposit amount
        address payable user; // User's address who made the reservation
        address payable owner; // Owner's address of the store
        ReservationStatus status; // Reservation status
    }

    // Enumeration for reservation status
    enum ReservationStatus { Pending, Confirmed, CancelledByUser, CancelledByOwner, NoShow }

    // Mapping to store reservation information based on reservation ID
    mapping(uint256 => Reservation) public reservations;

    // Event for reservation creation
    event ReservationCreated(uint256 id, address user);

    // Function to create a reservation
    function createReservation(uint256 _reservationId, address payable _owner, uint256 _depositAmount) external {
        // Check if a reservation with the same ID already exists
        require(reservations[_reservationId].user == address(0), "Reservation with this ID already exists.");

        // Create a new reservation
        Reservation storage newReservation = reservations[_reservationId];
        newReservation.id = _reservationId;
        newReservation.depositAmount = _depositAmount;
        newReservation.user = payable(msg.sender);
        newReservation.owner = _owner;
        newReservation.status = ReservationStatus.Pending;
    }
}

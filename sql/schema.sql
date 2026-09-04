-- ============================================================
-- Railway Reservation Database
-- Relational Schema
-- MSc Data Science - Database Systems Coursework
--
-- Portfolio implementation based on the coursework ERD,
-- relational schema and BCNF analysis.
-- ============================================================


-- ============================================================
-- 1. STATION
-- ============================================================

CREATE TABLE Station (
    StationCode CHAR(3) PRIMARY KEY,
    StationName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,

    CONSTRAINT chk_station_code
        CHECK (CHAR_LENGTH(StationCode) = 3)
);


-- ============================================================
-- 2. TRAIN
-- ============================================================

CREATE TABLE Train (
    UniqueTrainNumber VARCHAR(20) PRIMARY KEY,
    SourceStationCode CHAR(3) NOT NULL,
    DestinationStationCode CHAR(3) NOT NULL,
    TrainName VARCHAR(100),

    CONSTRAINT fk_train_source
        FOREIGN KEY (SourceStationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT fk_train_destination
        FOREIGN KEY (DestinationStationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT chk_train_stations
        CHECK (
            SourceStationCode <> DestinationStationCode
        )
);


-- ============================================================
-- 3. COACH
-- Each coach belongs to a particular train.
-- ============================================================

CREATE TABLE Coach (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    ClassType VARCHAR(20) DEFAULT 'Standard',
    SeatCapacity INTEGER NOT NULL,

    PRIMARY KEY (
        UniqueTrainNumber,
        CoachNumber
    ),

    CONSTRAINT fk_coach_train
        FOREIGN KEY (UniqueTrainNumber)
        REFERENCES Train(UniqueTrainNumber),

    CONSTRAINT chk_coach_class
        CHECK (
            ClassType IN (
                'First',
                'Second',
                'Sleeper',
                'Standard'
            )
        ),

    CONSTRAINT chk_coach_capacity
        CHECK (SeatCapacity > 0)
);


-- ============================================================
-- 4. SEAT
-- Weak entity dependent on TRAIN and COACH.
-- ============================================================

CREATE TABLE Seat (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    SeatNumber INTEGER NOT NULL,
    IsWindow BOOLEAN NOT NULL,
    IsForwardFacing BOOLEAN NOT NULL,
    IsAisle BOOLEAN NOT NULL,

    PRIMARY KEY (
        UniqueTrainNumber,
        CoachNumber,
        SeatNumber
    ),

    CONSTRAINT fk_seat_coach
        FOREIGN KEY (
            UniqueTrainNumber,
            CoachNumber
        )
        REFERENCES Coach(
            UniqueTrainNumber,
            CoachNumber
        ),

    CONSTRAINT chk_seat_number
        CHECK (SeatNumber > 0)
);


-- ============================================================
-- 5. TRAIN SCHEDULE
-- Weak entity dependent on TRAIN.
--
-- ScheduleID acts as the discriminator for individual
-- scheduled services belonging to a train.
-- ============================================================

CREATE TABLE TrainSchedule (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    ScheduleID INTEGER NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    DepartureTimeAtSource TIME NOT NULL,
    ArrivalTimeAtDestination TIME NOT NULL,
    JourneyDate DATE NOT NULL,

    PRIMARY KEY (
        UniqueTrainNumber,
        ScheduleID
    ),

    CONSTRAINT fk_schedule_train
        FOREIGN KEY (UniqueTrainNumber)
        REFERENCES Train(UniqueTrainNumber),

    CONSTRAINT chk_schedule_id
        CHECK (ScheduleID > 0),

    CONSTRAINT chk_day_of_week
        CHECK (
            DayOfWeek IN (
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
            )
        )
);


-- ============================================================
-- 6. INTERMEDIATE STATION
-- Weak entity representing an ordered stop within a
-- particular scheduled train service.
-- ============================================================

CREATE TABLE IntermediateStation (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    ScheduleID INTEGER NOT NULL,
    SequenceNumber INTEGER NOT NULL,
    StationCode CHAR(3) NOT NULL,
    ArrivalTime TIME,
    DepartureTimeAtSource TIME,

    PRIMARY KEY (
        UniqueTrainNumber,
        ScheduleID,
        SequenceNumber
    ),

    CONSTRAINT fk_intermediate_schedule
        FOREIGN KEY (
            UniqueTrainNumber,
            ScheduleID
        )
        REFERENCES TrainSchedule(
            UniqueTrainNumber,
            ScheduleID
        ),

    CONSTRAINT fk_intermediate_station
        FOREIGN KEY (StationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT chk_sequence_number
        CHECK (SequenceNumber > 0),

    CONSTRAINT uq_schedule_station
        UNIQUE (
            UniqueTrainNumber,
            ScheduleID,
            StationCode
        )
);


-- ============================================================
-- 7. PASSENGER
-- Strong entity identified by email address.
-- ============================================================

CREATE TABLE Passenger (
    Email VARCHAR(255) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    DateOfBirth DATE NOT NULL,
    PhoneNumber VARCHAR(30),
    Nationality VARCHAR(100),
    Gender VARCHAR(50)
);


-- ============================================================
-- 8. BOOKING
--
-- PassengerEmail materialises the Passenger-to-Booking
-- relationship from the conceptual design so the SQL schema
-- has explicit referential integrity.
-- ============================================================

CREATE TABLE Booking (
    BookingID VARCHAR(30) PRIMARY KEY,
    PassengerEmail VARCHAR(255) NOT NULL,
    JourneyDate DATE NOT NULL,
    BookingDateTime TIMESTAMP NOT NULL,
    NumberOfPassengers INTEGER NOT NULL,
    PaymentStatus VARCHAR(30),
    BookingChannel VARCHAR(50),
    CancellationReason VARCHAR(255),
    BookingStatus VARCHAR(30) DEFAULT 'Pending',

    CONSTRAINT fk_booking_passenger
        FOREIGN KEY (PassengerEmail)
        REFERENCES Passenger(Email),

    CONSTRAINT chk_number_passengers
        CHECK (NumberOfPassengers > 0)
);


-- ============================================================
-- 9. TICKET
-- Weak entity dependent on BOOKING.
--
-- UniqueReferenceCode is the discriminator and is unique
-- within its parent booking.
-- ============================================================

CREATE TABLE Ticket (
    BookingID VARCHAR(30) NOT NULL,
    UniqueReferenceCode VARCHAR(30) NOT NULL,
    ClassOfTravel VARCHAR(20) NOT NULL,
    TicketCost DECIMAL(10, 2) NOT NULL,
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    SeatNumber INTEGER NOT NULL,

    PRIMARY KEY (
        BookingID,
        UniqueReferenceCode
    ),

    CONSTRAINT fk_ticket_booking
        FOREIGN KEY (BookingID)
        REFERENCES Booking(BookingID),

    CONSTRAINT fk_ticket_seat
        FOREIGN KEY (
            UniqueTrainNumber,
            CoachNumber,
            SeatNumber
        )
        REFERENCES Seat(
            UniqueTrainNumber,
            CoachNumber,
            SeatNumber
        ),

    CONSTRAINT chk_ticket_class
        CHECK (
            ClassOfTravel IN (
                'First',
                'Second',
                'Sleeper',
                'Standard'
            )
        ),

    CONSTRAINT chk_ticket_cost
        CHECK (TicketCost >= 0)
);


-- ============================================================
-- 10. SEAT RESERVATION
--
-- The original coursework identifies TicketReferenceCode as
-- the reservation identifier. BookingID is also retained here
-- so the reservation can reference the composite TICKET key
-- unambiguously.
-- ============================================================

CREATE TABLE SeatReservation (
    BookingID VARCHAR(30) NOT NULL,
    TicketReferenceCode VARCHAR(30) NOT NULL,
    ClassOfTravel VARCHAR(20) NOT NULL,
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    SeatNumber INTEGER NOT NULL,
    BoardingStationCode CHAR(3) NOT NULL,
    DestinationStationCode CHAR(3) NOT NULL,
    ReservationStatus VARCHAR(30) DEFAULT 'Pending',

    PRIMARY KEY (
        BookingID,
        TicketReferenceCode
    ),

    CONSTRAINT fk_reservation_ticket
        FOREIGN KEY (
            BookingID,
            TicketReferenceCode
        )
        REFERENCES Ticket(
            BookingID,
            UniqueReferenceCode
        ),

    CONSTRAINT fk_reservation_seat
        FOREIGN KEY (
            UniqueTrainNumber,
            CoachNumber,
            SeatNumber
        )
        REFERENCES Seat(
            UniqueTrainNumber,
            CoachNumber,
            SeatNumber
        ),

    CONSTRAINT fk_reservation_boarding
        FOREIGN KEY (BoardingStationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT fk_reservation_destination
        FOREIGN KEY (DestinationStationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT chk_reservation_class
        CHECK (
            ClassOfTravel IN (
                'First',
                'Second',
                'Sleeper',
                'Standard'
            )
        ),

    CONSTRAINT chk_reservation_stations
        CHECK (
            BoardingStationCode <> DestinationStationCode
        )
);


-- ============================================================
-- 11. PAYMENT
-- ============================================================

CREATE TABLE Payment (
    PaymentID VARCHAR(30) PRIMARY KEY,
    BookingID VARCHAR(30) NOT NULL,
    PaymentAmount DECIMAL(10, 2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    PaymentDateTime TIMESTAMP NOT NULL,
    PaymentStatus VARCHAR(30) DEFAULT 'Pending',
    Currency CHAR(3) NOT NULL,
    ReferenceCode VARCHAR(50),

    CONSTRAINT fk_payment_booking
        FOREIGN KEY (BookingID)
        REFERENCES Booking(BookingID),

    CONSTRAINT chk_payment_amount
        CHECK (PaymentAmount > 0),

    CONSTRAINT chk_payment_status
        CHECK (
            PaymentStatus IN (
                'Pending',
                'Completed',
                'Refunded',
                'Failed'
            )
        ),

    CONSTRAINT chk_payment_method
        CHECK (
            PaymentMethod IN (
                'Debit Card',
                'Credit Card',
                'Gift Card'
            )
        )
);


-- ============================================================
-- INDEXES
-- ============================================================

-- Train route lookups
CREATE INDEX idx_train_source
    ON Train(SourceStationCode);

CREATE INDEX idx_train_destination
    ON Train(DestinationStationCode);


-- Coach and seat lookups
CREATE INDEX idx_coach_train
    ON Coach(UniqueTrainNumber);

CREATE INDEX idx_seat_coach
    ON Seat(UniqueTrainNumber, CoachNumber);


-- Schedule lookups
CREATE INDEX idx_schedule_date
    ON TrainSchedule(JourneyDate);

CREATE INDEX idx_schedule_train
    ON TrainSchedule(UniqueTrainNumber);

CREATE INDEX idx_schedule_day
    ON TrainSchedule(DayOfWeek);


-- Intermediate station / route searches
CREATE INDEX idx_intermediate_station
    ON IntermediateStation(StationCode);

CREATE INDEX idx_intermediate_schedule
    ON IntermediateStation(
        UniqueTrainNumber,
        ScheduleID
    );


-- Passenger and booking searches
CREATE INDEX idx_passenger_dob
    ON Passenger(DateOfBirth);

CREATE INDEX idx_booking_passenger
    ON Booking(PassengerEmail);

CREATE INDEX idx_booking_journey_date
    ON Booking(JourneyDate);

CREATE INDEX idx_booking_status
    ON Booking(BookingStatus);

CREATE INDEX idx_booking_payment_status
    ON Booking(PaymentStatus);


-- Ticket searches
CREATE INDEX idx_ticket_booking
    ON Ticket(BookingID);

CREATE INDEX idx_ticket_train
    ON Ticket(UniqueTrainNumber);

CREATE INDEX idx_ticket_seat
    ON Ticket(
        UniqueTrainNumber,
        CoachNumber,
        SeatNumber
    );


-- Reservation searches
CREATE INDEX idx_reservation_train
    ON SeatReservation(UniqueTrainNumber);

CREATE INDEX idx_reservation_seat
    ON SeatReservation(
        UniqueTrainNumber,
        CoachNumber,
        SeatNumber
    );

CREATE INDEX idx_reservation_boarding
    ON SeatReservation(BoardingStationCode);

CREATE INDEX idx_reservation_destination
    ON SeatReservation(DestinationStationCode);


-- Payment searches
CREATE INDEX idx_payment_booking
    ON Payment(BookingID);

CREATE INDEX idx_payment_status
    ON Payment(PaymentStatus);

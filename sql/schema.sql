-- ============================================================
-- Railway Reservation Database
-- Relational Schema
-- MSc Data Science - Database Systems Coursework
-- ============================================================


-- ------------------------------------------------------------
-- STATION
-- ------------------------------------------------------------

CREATE TABLE Station (
    StationCode CHAR(3) PRIMARY KEY,
    StationName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,

    CONSTRAINT chk_station_code
        CHECK (CHAR_LENGTH(StationCode) = 3),

    CONSTRAINT uq_station_name_city
        UNIQUE (StationName, City)
);


-- ------------------------------------------------------------
-- TRAIN
-- ------------------------------------------------------------

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

    CONSTRAINT chk_different_stations
        CHECK (SourceStationCode <> DestinationStationCode)
);


-- ------------------------------------------------------------
-- COACH
-- A coach is identified within a particular train.
-- ------------------------------------------------------------

CREATE TABLE Coach (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    ClassType VARCHAR(20) DEFAULT 'Standard',
    SeatCapacity INTEGER NOT NULL,

    PRIMARY KEY (UniqueTrainNumber, CoachNumber),

    CONSTRAINT fk_coach_train
        FOREIGN KEY (UniqueTrainNumber)
        REFERENCES Train(UniqueTrainNumber),

    CONSTRAINT chk_class_type
        CHECK (
            ClassType IN ('First', 'Second', 'Sleeper', 'Standard')
        ),

    CONSTRAINT chk_seat_capacity
        CHECK (SeatCapacity > 0)
);


-- ------------------------------------------------------------
-- SEAT
-- Weak entity dependent on TRAIN and COACH.
-- ------------------------------------------------------------

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


-- ------------------------------------------------------------
-- TRAIN SCHEDULE
-- Weak entity representing scheduled train services.
-- ------------------------------------------------------------

CREATE TABLE TrainSchedule (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    ScheduleID INTEGER NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    DepartureTimeAtSource TIME,
    ArrivalTimeAtDestination TIME,
    JourneyDate DATE NOT NULL,

    PRIMARY KEY (
        UniqueTrainNumber,
        ScheduleID
    ),

    CONSTRAINT fk_schedule_train
        FOREIGN KEY (UniqueTrainNumber)
        REFERENCES Train(UniqueTrainNumber),

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


-- ------------------------------------------------------------
-- INTERMEDIATE STATION
-- Weak entity representing ordered stops along a train route.
-- ------------------------------------------------------------

CREATE TABLE IntermediateStation (
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    SequenceNumber INTEGER NOT NULL,
    StationCode CHAR(3) NOT NULL,
    ArrivalTime TIME,
    DepartureTimeAtSource TIME,

    PRIMARY KEY (
        UniqueTrainNumber,
        SequenceNumber
    ),

    CONSTRAINT fk_intermediate_train
        FOREIGN KEY (UniqueTrainNumber)
        REFERENCES Train(UniqueTrainNumber),

    CONSTRAINT fk_intermediate_station
        FOREIGN KEY (StationCode)
        REFERENCES Station(StationCode),

    CONSTRAINT chk_sequence_number
        CHECK (SequenceNumber > 0)
);


-- ------------------------------------------------------------
-- PASSENGER
-- ------------------------------------------------------------

CREATE TABLE Passenger (
    Email VARCHAR(255) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    DateOfBirth DATE NOT NULL,
    PhoneNumber VARCHAR(30),
    Nationality VARCHAR(100),
    Gender VARCHAR(50)
);


-- ------------------------------------------------------------
-- BOOKING
-- ------------------------------------------------------------

CREATE TABLE Booking (
    BookingID VARCHAR(30) PRIMARY KEY,
    JourneyDate DATE NOT NULL,
    BookingDateTime TIMESTAMP NOT NULL,
    NumberOfPassengers INTEGER NOT NULL,
    PaymentStatus VARCHAR(30),
    BookingChannel VARCHAR(50),
    CancellationReason VARCHAR(255),
    BookingStatus VARCHAR(30) DEFAULT 'Pending',

    CONSTRAINT chk_passenger_count
        CHECK (NumberOfPassengers > 0)
);


-- ------------------------------------------------------------
-- TICKET
-- Weak entity dependent on BOOKING.
-- ------------------------------------------------------------

CREATE TABLE Ticket (
    BookingID VARCHAR(30) NOT NULL,
    UniqueReferenceCode VARCHAR(30) NOT NULL,
    ClassOfTravel VARCHAR(20) NOT NULL,
    TicketCost DECIMAL(10, 2) NOT NULL,
    UniqueTrainNumber VARCHAR(20),
    CoachNumber VARCHAR(10),
    SeatNumber INTEGER,

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

    CONSTRAINT chk_ticket_cost
        CHECK (TicketCost >= 0),

    CONSTRAINT chk_ticket_class
        CHECK (
            ClassOfTravel IN (
                'First',
                'Second',
                'Sleeper',
                'Standard'
            )
        )
);


-- ------------------------------------------------------------
-- SEAT RESERVATION
-- ------------------------------------------------------------

CREATE TABLE SeatReservation (
    TicketReferenceCode VARCHAR(30) PRIMARY KEY,
    ClassOfTravel VARCHAR(20) NOT NULL,
    UniqueTrainNumber VARCHAR(20) NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    SeatNumber INTEGER NOT NULL,
    BoardingStationCode CHAR(3) NOT NULL,
    DestinationStationCode CHAR(3) NOT NULL,
    ReservationStatus VARCHAR(30) DEFAULT 'Pending',

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

    CONSTRAINT chk_reservation_stations
        CHECK (
            BoardingStationCode <> DestinationStationCode
        )
);


-- ------------------------------------------------------------
-- PAYMENT
-- ------------------------------------------------------------

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
-- Indexes
-- ============================================================

CREATE INDEX idx_train_source
    ON Train(SourceStationCode);

CREATE INDEX idx_train_destination
    ON Train(DestinationStationCode);

CREATE INDEX idx_coach_train
    ON Coach(UniqueTrainNumber);

CREATE INDEX idx_schedule_date
    ON TrainSchedule(JourneyDate);

CREATE INDEX idx_intermediate_station
    ON IntermediateStation(StationCode);

CREATE INDEX idx_booking_journey_date
    ON Booking(JourneyDate);

CREATE INDEX idx_booking_status
    ON Booking(BookingStatus);

CREATE INDEX idx_ticket_booking
    ON Ticket(BookingID);

CREATE INDEX idx_reservation_train
    ON SeatReservation(UniqueTrainNumber);

CREATE INDEX idx_payment_booking
    ON Payment(BookingID);

CREATE INDEX idx_payment_status
    ON Payment(PaymentStatus);

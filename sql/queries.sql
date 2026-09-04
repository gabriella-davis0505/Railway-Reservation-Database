-- ============================================================
-- Railway Reservation Database
-- SQL Queries
-- MSc Data Science - Database Systems Coursework
-- ============================================================


-- ------------------------------------------------------------
-- Query 1
-- Seats booked in second class between Loughborough and London
-- on a given date
-- ------------------------------------------------------------

SELECT
    ts.UniqueTrainNumber,
    COUNT(DISTINCT sr.TicketReferenceCode) AS SecondClassSeatsBooked
FROM TrainSchedule ts
JOIN IntermediateStation is_l
    ON is_l.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN IntermediateStation is_lo
    ON is_lo.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN SeatReservation sr
    ON sr.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN Ticket t
    ON t.UniqueReferenceCode = sr.TicketReferenceCode
WHERE ts.JourneyDate = DATE '2025-12-01'
    AND is_l.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'Loughborough'
    )
    AND is_lo.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'London'
    )
    AND is_l.SequenceNumber < is_lo.SequenceNumber
    AND t.ClassOfTravel = 'Second'
GROUP BY ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 2
-- Trains between Loughborough and London departing
-- Loughborough between 18:00 and 21:00
-- ------------------------------------------------------------

SELECT DISTINCT
    ts.UniqueTrainNumber
FROM TrainSchedule ts
JOIN IntermediateStation is_l
    ON is_l.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN IntermediateStation is_lo
    ON is_lo.UniqueTrainNumber = ts.UniqueTrainNumber
WHERE is_l.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'Loughborough'
    )
    AND is_lo.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'London'
    )
    AND is_l.SequenceNumber < is_lo.SequenceNumber
    AND is_l.DepartureTimeAtSource BETWEEN TIME '18:00' AND TIME '21:00';


-- ------------------------------------------------------------
-- Query 3
-- Trains between Loughborough and London departing between
-- 18:00 and 21:00 with First-class seat records
-- ------------------------------------------------------------

SELECT DISTINCT
    ts.UniqueTrainNumber
FROM TrainSchedule ts
JOIN IntermediateStation is_l
    ON is_l.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN IntermediateStation is_lo
    ON is_lo.UniqueTrainNumber = ts.UniqueTrainNumber
WHERE is_l.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'Loughborough'
    )
    AND is_lo.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'London'
    )
    AND is_l.SequenceNumber < is_lo.SequenceNumber
    AND is_l.DepartureTimeAtSource BETWEEN TIME '18:00' AND TIME '21:00'
    AND EXISTS (
        SELECT 1
        FROM SeatReservation sr
        JOIN Coach c
            ON sr.CoachNumber = c.CoachNumber
        WHERE sr.UniqueTrainNumber = ts.UniqueTrainNumber
            AND c.ClassType = 'First'
    );


-- ------------------------------------------------------------
-- Query 4
-- Number of First-class and Second-class tickets booked
-- for each train by year
-- ------------------------------------------------------------

SELECT
    ts.UniqueTrainNumber,
    EXTRACT(YEAR FROM ts.JourneyDate) AS Year,
    COUNT(
        CASE
            WHEN t.ClassOfTravel = 'Second' THEN 1
            ELSE NULL
        END
    ) AS SecondClassTickets,
    COUNT(
        CASE
            WHEN t.ClassOfTravel = 'First' THEN 1
            ELSE NULL
        END
    ) AS FirstClassTickets
FROM TrainSchedule ts
LEFT JOIN SeatReservation sr
    ON sr.UniqueTrainNumber = ts.UniqueTrainNumber
LEFT JOIN Ticket t
    ON t.UniqueReferenceCode = sr.TicketReferenceCode
GROUP BY
    ts.UniqueTrainNumber,
    EXTRACT(YEAR FROM ts.JourneyDate)
ORDER BY
    Year DESC,
    ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 5
-- Train generating the highest total ticket sales
-- ------------------------------------------------------------

WITH TrainRevenue AS (
    SELECT
        ts.UniqueTrainNumber,
        SUM(t.TicketCost) AS TotalSales
    FROM TrainSchedule ts
    JOIN SeatReservation sr
        ON sr.UniqueTrainNumber = ts.UniqueTrainNumber
    JOIN Ticket t
        ON t.UniqueReferenceCode = sr.TicketReferenceCode
    GROUP BY ts.UniqueTrainNumber
)
SELECT
    tr.UniqueTrainNumber,
    tr.TotalSales,
    ts.SourceStation,
    ts.DestinationStation
FROM TrainRevenue tr
JOIN TrainSchedule ts
    ON ts.UniqueTrainNumber = tr.UniqueTrainNumber
ORDER BY tr.TotalSales DESC
FETCH FIRST 1 ROW ONLY;


-- ------------------------------------------------------------
-- Query 6
-- Tickets booked by service time for trains travelling
-- between Sheffield and Loughborough during 2025
-- ------------------------------------------------------------

SELECT
    ts.UniqueTrainNumber,
    is_sh.DepartureTimeAtSource AS ServiceTime,
    COUNT(t.UniqueReferenceCode) AS TicketsBooked
FROM TrainSchedule ts
JOIN IntermediateStation is_sh
    ON is_sh.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN IntermediateStation is_lb
    ON is_lb.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN SeatReservation sr
    ON sr.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN Ticket t
    ON t.UniqueReferenceCode = sr.TicketReferenceCode
WHERE EXTRACT(YEAR FROM ts.JourneyDate) = 2025
    AND is_sh.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'Sheffield'
    )
    AND is_lb.StationCode = (
        SELECT StationCode
        FROM Station
        WHERE StationName = 'Loughborough'
    )
    AND is_sh.SequenceNumber < is_lb.SequenceNumber
GROUP BY
    ts.UniqueTrainNumber,
    is_sh.DepartureTimeAtSource
ORDER BY
    ServiceTime ASC,
    ts.UniqueTrainNumber;

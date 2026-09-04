-- ============================================================
-- Railway Reservation Database
-- SQL Queries
-- MSc Data Science - Database Systems Coursework
--
-- Portfolio version aligned with sql/schema.sql
-- ============================================================


-- ------------------------------------------------------------
-- Query 1
-- Number of Second-class seats booked between Loughborough
-- and London on a specified date
-- ------------------------------------------------------------

SELECT
    ts.UniqueTrainNumber,
    COUNT(t.UniqueReferenceCode) AS SecondClassSeatsBooked
FROM TrainSchedule ts
JOIN IntermediateStation is_l
    ON is_l.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN IntermediateStation is_lo
    ON is_lo.UniqueTrainNumber = ts.UniqueTrainNumber
JOIN Booking b
    ON b.JourneyDate = ts.JourneyDate
JOIN Ticket t
    ON t.BookingID = b.BookingID
    AND t.UniqueTrainNumber = ts.UniqueTrainNumber
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
GROUP BY ts.UniqueTrainNumber
ORDER BY ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 2
-- Trains between Loughborough and London departing
-- Loughborough between 18:00 and 21:00
-- ------------------------------------------------------------

SELECT DISTINCT
    ts.UniqueTrainNumber,
    is_l.DepartureTimeAtSource AS LoughboroughDepartureTime
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
    AND is_l.DepartureTimeAtSource
        BETWEEN TIME '18:00:00' AND TIME '21:00:00'
ORDER BY
    LoughboroughDepartureTime,
    ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 3
-- Trains between Loughborough and London departing between
-- 18:00 and 21:00 that contain First-class coaches
-- ------------------------------------------------------------

SELECT DISTINCT
    ts.UniqueTrainNumber,
    is_l.DepartureTimeAtSource AS LoughboroughDepartureTime
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
    AND is_l.DepartureTimeAtSource
        BETWEEN TIME '18:00:00' AND TIME '21:00:00'
    AND EXISTS (
        SELECT 1
        FROM Coach c
        WHERE c.UniqueTrainNumber = ts.UniqueTrainNumber
            AND c.ClassType = 'First'
    )
ORDER BY
    LoughboroughDepartureTime,
    ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 4
-- Number of First-class and Second-class tickets booked
-- for each train by year
--
-- LEFT JOIN is used so scheduled trains can still appear
-- when no matching tickets have been booked.
-- ------------------------------------------------------------

SELECT
    ts.UniqueTrainNumber,
    EXTRACT(YEAR FROM ts.JourneyDate) AS JourneyYear,

    COUNT(
        CASE
            WHEN t.ClassOfTravel = 'Second'
            THEN t.UniqueReferenceCode
        END
    ) AS SecondClassTickets,

    COUNT(
        CASE
            WHEN t.ClassOfTravel = 'First'
            THEN t.UniqueReferenceCode
        END
    ) AS FirstClassTickets

FROM TrainSchedule ts

LEFT JOIN Booking b
    ON b.JourneyDate = ts.JourneyDate

LEFT JOIN Ticket t
    ON t.BookingID = b.BookingID
    AND t.UniqueTrainNumber = ts.UniqueTrainNumber

GROUP BY
    ts.UniqueTrainNumber,
    EXTRACT(YEAR FROM ts.JourneyDate)

ORDER BY
    JourneyYear DESC,
    ts.UniqueTrainNumber;


-- ------------------------------------------------------------
-- Query 5
-- Train generating the highest total ticket sales
-- ------------------------------------------------------------

WITH TrainRevenue AS (
    SELECT
        t.UniqueTrainNumber,
        SUM(t.TicketCost) AS TotalSales
    FROM Ticket t
    WHERE t.UniqueTrainNumber IS NOT NULL
    GROUP BY t.UniqueTrainNumber
)

SELECT
    tr.UniqueTrainNumber,
    tr.TotalSales,
    source_station.StationName AS SourceStation,
    destination_station.StationName AS DestinationStation

FROM TrainRevenue tr

JOIN Train tn
    ON tn.UniqueTrainNumber = tr.UniqueTrainNumber

JOIN Station source_station
    ON source_station.StationCode = tn.SourceStationCode

JOIN Station destination_station
    ON destination_station.StationCode = tn.DestinationStationCode

ORDER BY tr.TotalSales DESC

FETCH FIRST 1 ROW ONLY;


-- ------------------------------------------------------------
-- Query 6
-- Number of tickets booked by service time for trains
-- travelling between Sheffield and Loughborough during 2025
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

LEFT JOIN Booking b
    ON b.JourneyDate = ts.JourneyDate

LEFT JOIN Ticket t
    ON t.BookingID = b.BookingID
    AND t.UniqueTrainNumber = ts.UniqueTrainNumber

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
    ServiceTime,
    ts.UniqueTrainNumber;

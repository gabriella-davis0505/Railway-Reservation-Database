# Railway Reservation Database

Relational database design project for a **Railway Reservation System**, developed as part of an MSc Data Science Database Systems module.

The project covers the full database design process, from conceptual modelling and schema development through to normalisation, performance considerations and SQL querying.

---

## Project Overview

The aim of this project was to design a relational database capable of representing the core operations of a railway reservation system.

The project followed the database development process:

**Entity Relationship Modelling → Relational Schema Design → Functional Dependency Analysis → BCNF Normalisation → Performance Analysis → SQL Queries**

The resulting design represents trains, stations, schedules, coaches, seats, passengers, bookings, tickets, reservations and payments while maintaining relationships between the different parts of the reservation system.

---

## Database Design

The database contains 11 main entities:

- `TRAIN`
- `STATION`
- `COACH`
- `SEAT`
- `TRAIN SCHEDULE`
- `INTERMEDIATE STATION`
- `PASSENGER`
- `BOOKING`
- `TICKET`
- `SEAT RESERVATION`
- `PAYMENT`

Both strong and weak entities were used where appropriate.

For example, entities such as `TRAIN`, `STATION`, `PASSENGER`, `BOOKING` and `PAYMENT` can be independently identified, while entities such as `SEAT`, `TRAIN SCHEDULE` and `TICKET` depend on identifying information from related entities.

---

## Entity Relationship Modelling

An Entity Relationship Diagram (ERD) was developed to define the structure of the Railway Reservation System before translating it into a relational schema.

The design models relationships including:

- trains and their source and destination stations;
- coaches belonging to trains;
- seats belonging to individual coaches;
- scheduled train services;
- intermediate stations along a route;
- passenger bookings;
- tickets associated with bookings;
- seat reservations;
- boarding and destination stations; and
- payments associated with bookings.

The complete ERD and design rationale are available in the coursework report.

---

## Relational Schema

The relational schema defines:

- primary keys;
- foreign keys;
- composite keys;
- weak-entity discriminators;
- domain constraints;
- referential integrity constraints;
- indexes; and
- proposed database triggers.

The SQL representation of the schema is available in:

```text
sql/schema.sql
```

Examples of constraints considered in the design include:

- source and destination stations cannot be identical;
- seat numbers must be positive;
- coach class types are restricted to valid travel classes;
- payment amounts must be greater than zero;
- boarding and destination stations must be different;
- seat reservations must reference valid seats; and
- payments must reference valid bookings.

---

## Database Normalisation

Functional dependencies were identified for each entity and the schema was evaluated against **Boyce-Codd Normal Form (BCNF)**.

The analysis examined whether every determinant was a candidate key and whether any attributes introduced:

- partial dependencies;
- transitive dependencies;
- non-key determinants; or
- unnecessary redundancy.

One example identified during the analysis was `Station Code → Station Name`. Storing `Station Name` within `INTERMEDIATE STATION` would introduce a non-key determinant, so station information is instead maintained within the authoritative `STATION` relation and retrieved through joins.

This approach reduces duplication and helps prevent insertion, deletion and update anomalies.

---

## Performance and Scalability

The project also considered how the schema could perform within a larger production railway reservation system.

Performance considerations included:

### Indexing

Indexes were proposed for frequently searched and joined attributes, including:

- train numbers;
- station codes;
- journey dates;
- booking IDs;
- payment status;
- reservation information; and
- foreign-key columns.

### Partitioning

For high-volume tables such as:

- `BOOKING`
- `TICKET`
- `SEAT RESERVATION`
- `PAYMENT`

horizontal partitioning by attributes such as journey date or booking identifier could improve query performance and maintenance.

### Concurrency

A live railway booking system may receive many simultaneous requests for the same train or seat.

The project therefore considered techniques such as:

- optimistic or pessimistic locking;
- unique seat constraints;
- workload management; and
- database queues during periods of high demand.

These techniques could help reduce the risk of conflicting reservations and double bookings.

---

## SQL Queries

The repository contains six SQL queries based on the normalised database design.

They are available in:

```text
sql/queries.sql
```

### Query 1

Determine the number of **Second-class seats booked between Loughborough and London on a specified date**.

Demonstrates:

- multiple joins;
- subqueries;
- filtering;
- route ordering;
- aggregation; and
- `COUNT(DISTINCT ...)`.

### Query 2

Find trains travelling between **Loughborough and London** that depart Loughborough between **18:00 and 21:00**.

Demonstrates:

- route filtering;
- intermediate-station joins;
- time filtering; and
- sequence-based route validation.

### Query 3

Find trains between Loughborough and London within the specified departure period while restricting results to trains with **First-class seat records**.

Demonstrates:

- `EXISTS`;
- nested queries;
- joins; and
- class-based filtering.

### Query 4

Determine the number of **First-class and Second-class tickets booked for each train by year**, including services with no bookings.

Demonstrates:

- `LEFT JOIN`;
- conditional aggregation;
- `CASE`;
- `COUNT`;
- `GROUP BY`; and
- year extraction.

### Query 5

Determine the train that has generated the **highest total ticket sales**.

Demonstrates:

- Common Table Expressions (`WITH`);
- `SUM`;
- aggregation;
- sorting; and
- revenue analysis.

### Query 6

Determine the number of tickets booked for each service time for trains travelling between **Sheffield and Loughborough during 2025**.

Demonstrates:

- date filtering;
- route validation;
- aggregation;
- joins; and
- service-time analysis.

---

## Repository Structure

```text
railway-reservation-database/
│
├── README.md
├── Database Systems Coursework.pdf
│
└── sql/
    ├── schema.sql
    └── queries.sql
```

---

## Files

### `sql/schema.sql`

SQL representation of the relational database schema, including:

- tables;
- primary keys;
- foreign keys;
- composite keys;
- constraints; and
- indexes.

### `sql/queries.sql`

Collection of analytical and operational SQL queries developed for the railway reservation database.

### `Database Systems Coursework.pdf`

The complete academic report containing:

- Entity Relationship Diagram;
- schema design and rationale;
- strong and weak entity analysis;
- constraints;
- proposed indexes and triggers;
- functional dependencies;
- BCNF normalisation;
- performance and representational analysis;
- SQL queries; and
- discussion of future enhancements.

---

## SQL Techniques Demonstrated

This project demonstrates the use of:

- relational database design;
- Entity Relationship Diagrams;
- primary and foreign keys;
- composite keys;
- referential integrity;
- functional dependencies;
- BCNF normalisation;
- SQL joins;
- subqueries;
- Common Table Expressions;
- `EXISTS`;
- aggregate functions;
- conditional aggregation;
- `GROUP BY`;
- `ORDER BY`;
- date and time filtering;
- indexes; and
- database constraints.

---

## Future Enhancements

The coursework identified several ways in which the database could be expanded for a production railway system.

Potential extensions include:

- service-capacity management;
- dynamic pricing;
- promotions;
- disruption management;
- exception timetables;
- customer notifications;
- improved seat-availability management;
- additional security controls;
- partitioning for large transactional tables; and
- concurrency controls for high-demand booking periods.

These additions would allow the core normalised database design to support a larger and more operationally complex reservation platform.

---

## Skills Demonstrated

This project demonstrates experience in:

- SQL;
- relational database design;
- data modelling;
- Entity Relationship Modelling;
- database normalisation;
- BCNF;
- functional dependency analysis;
- schema design;
- database constraints;
- indexing strategies;
- query design;
- database performance analysis;
- analytical SQL; and
- translating business requirements into a relational data model.

---

## Academic Context

This repository contains work completed as part of an **MSc Data Science Database Systems module**.

The project has been included in my data science portfolio to demonstrate SQL, database design, data modelling and relational database skills.

---

## Author

**Gabriella Davis**

MSc Data Science

GitHub: `gabriella-davis0505`

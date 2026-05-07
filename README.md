# Banking Database System & Credit Card Management

## About the Project
This repository contains a comprehensive semester project developed for the "Database Systems" course. It simulates a relational database system for "Delta Bank," focusing on customer management, accounts, and credit card transactions. The project covers the entire database lifecycle, from initial conceptual design to advanced programmatic implementations and backend integration.

## Key Features

### 1. Database Design & Implementation
* **Entity-Relationship (ER) Modeling:** Conceptual design translated into a robust relational schema[cite: 21].
* **SQL Server Implementation:** Creation of tables, constraints, and relationships[cite: 21].

### 2. Advanced Data Retrieval (SQL)
* Developed 16 complex SQL queries handling business logic such as aggregations, multi-table `JOIN`s, and date manipulations.
* Implemented Relational Algebra expressions for core queries.
* Explored modern development practices by comparing handwritten SQL solutions with GenAI-generated queries.

### 3. Database Programming (T-SQL)
* **Triggers:** Implemented pre-insert validation logic to automatically reject transactions if the purchase amount plus the current balance exceeds the card's credit limit.
* **Stored Procedures & Cursors:** Created a stored procedure utilizing logical cursors to dynamically calculate staggered transaction fees/cashback (1%, 2%, or 3%) based on the specific day of the month a transaction occurred.

### 4. Backend Application (Java JDBC)
Developed a Java console application to interact with the SQL Server database:
* **Safe Deletion:** A module that completely deletes a credit card and safely cascades the deletion to all associated purchases and payment records.
* **Statement Generation:** A module that generates a formatted monthly statement for a specific credit card, displaying cardholder details, monthly transactions, store categories, and the updated current balance.

## Tech Stack
* **Database:** Microsoft SQL Server (T-SQL)
* **Backend:** Java (JDBC)
* **Concepts:** ER Modeling, Relational Algebra, Triggers, Stored Procedures, Cursors

## Repository Structure
* `/sql/` - Contains the DDL scripts for table creation and DML scripts for queries/triggers.
* `/java/` - Contains the Java source code for the JDBC application.
* `/docs/` - Contains the ER Diagram and relational schema documentation.

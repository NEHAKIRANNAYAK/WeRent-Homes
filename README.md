WeRent Homes – Real Estate Management System

Introduction

WeRent Homes is a relational database–driven web application that supports the operations of a real estate rental platform. The system enables renters to search and book properties, manage payment methods, and track rewards, while agents can list properties and review booking activities. The project demonstrates database modeling, normalization, SQL implementation, and full-stack application development using Flask and PostgreSQL.

System Capabilities

Renter Functionality
	•	Login using registered email
	•	Search for properties using filters: city, category, rooms, price range, and sorting options
	•	Book available properties using stored payment cards
	•	Earn reward points based on booking price
	•	Add and delete credit cards (cards associated with bookings cannot be deleted)
	•	View and cancel bookings

Agent Functionality
	•	Login using registered email
	•	Add new property listings with full details
	•	View all managed properties
	•	Delete properties not associated with bookings
	•	View bookings made on their listed properties

Database Design

The database follows a fully normalized schema satisfying 1NF, 2NF, and 3NF. Key design decisions include:
	•	Use of surrogate keys instead of email-based primary keys
	•	Separation of address details into a dedicated table to eliminate redundancy
	•	Decomposition of property details into category and attribute-based entities
	•	Enforcement of referential integrity through foreign key constraints

Technologies Used
	•	Python (Flask framework)
	•	PostgreSQL
	•	psycopg2-binary (database connectivity)
	•	Gunicorn (production server)
	•	HTML and Bootstrap for UI presentation

Access the web interface

http://127.0.0.1:5000/


Summary

WeRent Homes integrates database normalization principles with web-based data processing to deliver an end-to-end real estate management solution. Each operation within the application corresponds to executable SQL queries, ensuring consistency, correctness, and traceability between the interface and the underlying relational schema.

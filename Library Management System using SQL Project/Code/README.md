# Library Management System

## Overview
This project implements a comprehensive library management system using MySQL. The system tracks books, members, employees, branches, and book transactions (issuing/returning). The database supports various operations including CRUD, data analysis, and stored procedures.

## Database Schema
### Key Tables:
- **books**: Stores book details (title, author, category, availability)
- **members**: Tracks library members
- **employees**: Manages staff information
- **branch**: Contains library branch locations
- **issue_status**: Records book checkouts
- **return_status**: Tracks book returns

## Key Features

### 1. Data Analysis
The system provides valuable insights through SQL queries:
- **Popularity Metrics**: Top 5 most issued books, most active members/employees
- **Financial Analysis**: Revenue by book category
- **Inventory Management**: Identifies never-borrowed books
- **Branch Performance**: Employee counts and rental income by location
- **Membership Trends**: Yearly member registration statistics

### 2. Operational Procedures
- **Overdue Detection**: Identifies books overdue by >30 days
- **Return Processing**: `update_return_status` stored procedure handles book returns:
  - Updates inventory status
  - Records return details
  - Provides user confirmation

### 3. Data Management
- **CRUD Operations**: Full support for Create, Read, Update, Delete
- **CTAS Implementation**: Created `issued_books` table via CREATE TABLE AS SELECT
- **Data Integrity**: Enforced through foreign key constraints

## Sample Insights
- **Most Popular Book**: "Harry Potter and the Sorcerer's Stone"
- **Top Employee**: Laura Martinez (issued 6 books)
- **Most Active Member**: Ivy Martinez (issued 7 books)
- **Highest Revenue Category**: Dystopian ($54.99)
- **Largest Branch**: B001 (123 Main St) with 5 employees

## Technical Implementation
- MySQL database with normalized schema
- Comprehensive SQL scripts for:
  - Database creation (`Create DB.sql`)
  - Data population (`Insert data.sql`)
  - Operations (`Advanced SQL Operations.sql`)
  - Analysis (`Data Analysis & Findings.sql`)

## Usage
The system supports:
- Daily library operations
- Business intelligence reporting
- Inventory management
- Member/employee performance tracking

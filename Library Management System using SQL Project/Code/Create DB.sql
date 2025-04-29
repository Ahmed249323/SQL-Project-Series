-- Active: 1731697033678@@127.0.0.1@3306@library_db
-- This script creates a database and tables for a library management system.
-- It includes tables for branches and employees, with appropriate constraints.
-- The script also includes a check to ensure that the database and tables are created only if they do not already exist.

CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;
--- Create tables for library management system

--- Create table "branch" to store branch information
CREATE TABLE IF NOT EXISTS branch(
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10) ,
    branch_address VARCHAR(30) ,
    contact_no VARCHAR(15) 
);

-- Create table "employees" to store employee information
CREATE TABLE IF NOT EXISTS employees(
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30) ,
    position VARCHAR(40) ,
    salary NUMERIC(10,2) ,
    branch_id VARCHAR(10) ,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Create table "books" to store book information
CREATE TABLE IF NOT EXISTS books (
    isbn VARCHAR (50) PRIMARY KEY,
    book_title VARCHAR (80)  ,
    category VARCHAR (30) ,
    rental_price NUMERIC(10,2) ,
    status VARCHAR(10) ,
    author VARCHAR(30) ,
    publisher VARCHAR(30) 

);

-- Create table "members" to store member information

CREATE TABLE IF NOT EXISTS members(
    member_id VARCHAR (10) PRIMARY KEY,
    member_name VARCHAR (30) ,
    member_address VARCHAR (30) ,
    reg_date DATE 
);

-- Create table "issue_status" to store information about issued books
CREATE TABLE IF NOT EXISTS issue_status(
    issued_id VARCHAR (10) PRIMARY KEY,
    issued_member_id VARCHAR (30) ,
    issued_book_name VARCHAR (50) ,
    issued_date DATE ,
    issued_book_isbn VARCHAR (50) ,
    issued_emp_id VARCHAR (10) ,
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)

);

-- Create table "return_status" to store information about returned books
CREATE TABLE IF NOT EXISTS return_status(
    return_id VARCHAR (10) PRIMARY KEY,
    issued_id VARCHAR (30) ,
    return_book_name VARCHAR (80) ,
    return_date DATE ,
    return_book_isbn VARCHAR (50) ,
    FOREIGN KEY (issued_id) REFERENCES issue_status(issued_id),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


ALTER TABLE issue_status
MODIFY COLUMN issued_book_name VARCHAR(100);


SHOW CREATE TABLE return_status;

ALTER TABLE return_status
DROP FOREIGN KEY return_status_ibfk_1;




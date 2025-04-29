-- Active: 1731697033678@@127.0.0.1@3306@library_db
-- CRUD Operations
    --- Create: Inserted sample records into the books table.
    --- Read: Retrieved and displayed data from various tables.
    --- Update: Updated records in the employees table.
    --- Delete: Removed records from the members table as needed.
-- CTAS
-- Objective: Create a new table "issued_books" to store information about issued books.
-- This table will be created using the CREATE TABLE AS SELECT (CTAS) statement.

USE library_db;
---------------------------------------------------------------------------------------------------------------------------------


-- Create: Insert sample records into the books table

INSERT INTO BOOKS(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES
('978-3-16-148410-10', 'The Great Gatsby', 'Fiction', 10.99, 'Available', 'F. Scott Fitzgerald', 'Scribner'),
('978-1-56619-909-41', 'To Kill a Mockingbird', 'Fiction', 12.99, 'Available', 'Harper Lee', 'J.B. Lippincott & Co.'),
('978-0-7432-7356-53', '1984', 'Dystopian', 15.99, 'Available', 'George Orwell', 'Secker & Warburg'),
('978-0-452-28423-45', 'Pride and Prejudice', 'Romance', 8.99, 'Available', 'Jane Austen', 'T. Egerton'),
('978-0-7432-7356-52', 'The Catcher in the Rye', 'Fiction', 9.99, 'Available', 'J.D. Salinger', 'Little, Brown and Company'),
('978-1-4028-9462-60', 'The Hobbit', 'Fantasy', 14.99, 'Available', 'J.R.R. Tolkien', 'George Allen & Unwin');


---------------------------------------------------------------------------------------------------------------------------------


-- Read: Retrieve and display data from the books table
SELECT * FROM BOOKS;
SELECT * FROM BOOKS
    WHERE category = 'Fiction';


---------------------------------------------------------------------------------------------------------------------------------


-- Update: Update records in the employees table
UPDATE EMPLOYEES
SET salary = salary * 1.10
WHERE position = 'Librarian';




-- Delete: Remove records from the members table
DELETE FROM MEMBERS
WHERE member_id = 'M001';

--------------------------------------------------------------------------------------------------------------------------


-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
       COUNT(*) AS total_issued_books
FROM issue_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------  CTAS  ---------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-- Objective: Create a new table "issued_books" to store information about issued books.
-- This table will be created using the CREATE TABLE AS SELECT (CTAS) statement.

USE library_db;
-- Retrieve all records from the books table (for verification or debugging purposes)
SELECT * FROM books;

-- Create a new table "issued_books" using the CTAS (CREATE TABLE AS SELECT) statement.
-- This table will store information about books and the total number of times they have been issued.
CREATE TABLE issued_books AS
SELECT 
    B.isbn, -- ISBN of the book
    B.book_title, -- Title of the book
    COUNT(IST.issued_book_isbn) AS total_issued_books -- Total number of times the book has been issued
FROM books AS B
JOIN issue_status AS IST
ON B.isbn = IST.issued_book_isbn -- Join books with issue_status on ISBN
GROUP BY B.isbn, B.book_title; -- Group by ISBN and book title to calculate the total issued count

show tables
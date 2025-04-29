-- Active: 1731697033678@@127.0.0.1@3306@library_db
USE library_db;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.


SELECT 
    i.issued_id,
    m.member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    DATEDIFF(CURRENT_DATE, i.issued_date) AS days_overdue
FROM members m 
JOIN issue_status i 
    ON m.member_id = i.issued_member_id
JOIN books b
     ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r 
    ON i.issued_id = r.issued_id
WHERE
    r.return_id IS NOT NULL
    AND
    DATEDIFF(CURRENT_DATE, i.issued_date) > 30

ORDER BY 1




---------------------------------------------------------------------------------------------------






    /*
        Procedure: update_return_status
        Description: This procedure manages the process of returning a book. It updates the return status, 
                     marks the book as available in the inventory, and provides a thank-you message to the user.
        Parameters:
            - p_return_id: The unique identifier for the return transaction.
            - p_issued_id: The unique identifier for the issued transaction.
            - p_book_quality: The condition of the book being returned (e.g., Good, Damaged).
        Steps:
            1. Retrieve the book's ISBN and name based on the issued transaction ID.
            2. Insert a new record into the return_status table with the provided details.
            3. Update the books table to mark the book as available for borrowing.
            4. Display a thank-you message with the book's name to confirm the return process.
    */
DELIMITER $$
    DROP PROCEDURE IF EXISTS update_return_status$$
    CREATE PROCEDURE update_return_status(
        IN p_return_id VARCHAR(10),
        IN p_issued_id VARCHAR(10),
        IN p_book_quality VARCHAR(10)
    )
    BEGIN
        DECLARE v_isbn VARCHAR(50);
        DECLARE v_book_name VARCHAR(80);

        SELECT issued_book_isbn, issued_book_name
        INTO v_isbn, v_book_name
        FROM issue_status
        WHERE issued_id = p_issued_id;

        INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
        VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

        UPDATE books
        SET status = 'yes'
        WHERE isbn = v_isbn;

        SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

    END$$
DELIMITER ;

-- Retrieve details of the book with the specified ISBN
SELECT * FROM books 
WHERE isbn = '978-0-307-58837-1';

-- Retrieve return status details for the specified issued ID
SELECT * FROM return_status 
WHERE issued_id = 'IS135';


CALL update_return_status('RS138', 'IS135', 'Good');







------------------------------------------------------------------------------------------------------------------------------


-- This query retrieves information about library branches, including:
-- - Branch ID, Manager ID, and Branch Address
-- - Total number of issued books and returned books for each branch
-- - Total rental income generated from issued books
-- The data is grouped by branch and sorted by Branch ID.
SELECT  
    branch.branch_id,
    branch.manager_id,
    branch.branch_address,
    COUNT(issued_books.issued_id) AS total_issued_books,
    COUNT(return_status.return_id) AS total_returned_books,
    SUM(books.rental_price) AS total_rental_income
FROM branch
JOIN employees 
    ON branch.branch_id = employees.branch_id
JOIN issue_status AS issued_books 
    ON employees.emp_id = issued_books.issued_emp_id
LEFT JOIN return_status 
    ON issued_books.issued_id = return_status.issued_id
JOIN books 
    ON issued_books.issued_book_isbn = books.isbn
GROUP BY branch.branch_id, branch.manager_id, branch.branch_address
ORDER BY branch.branch_id;


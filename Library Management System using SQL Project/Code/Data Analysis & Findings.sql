-- Active: 1731697033678@@127.0.0.1@3306@library_db
-- Data Analysis & Findings
USE library_db;
--------------------------------------------------------------------------------------------------------------

-- What are the top 5 most issued books?
-- OR 
--  Which books are the most popular?


-- This query retrieves the top 5 most issued books from the library.
-- It selects the book title and the total number of times each book has been issued.
-- The data is fetched by joining the 'books' table (B) with the 'issue_status' table (IST)
-- using the 'isbn' column from the 'books' table and the 'issued_book_isbn' column from the 'issue_status' table.
-- The results are grouped by book title and sorted in descending order based on the total issued count.
-- Finally, the LIMIT clause ensures that only the top 5 books with the highest issue counts are returned.
SELECT 
        B.book_title,
        COUNT(IST.issued_book_isbn) AS total_issued_books
FROM books B
JOIN issue_status IST 
ON B.isbn = IST.issued_book_isbn 
GROUP BY B.book_title
ORDER BY total_issued_books DESC
LIMIT 5;

--1) Harry Potter and the Sorcerers Stone	
--2) The Great Gatsby	
--3) Animal Farm	
--4) To Kill a Mockingbird	
--5) The Stand	

--------------------------------------------------------------------------------------------------------------


-- Which employees issue the most books?


-- This query retrieves the top 5 employees who have issued the highest number of books.
-- It joins the 'issue_status' table with the 'employees' table using the 'issued_emp_id' and 'emp_id' columns.
-- The query groups the data by employee name ('emp_name') and calculates the total number of books issued by each employee.
-- The results are sorted in descending order based on the total number of issued books ('total_issued_books').
-- Finally, the query limits the output to the top 5 employees.
SELECT
    emp_name,
    COUNT(issued_book_isbn) AS total_issued_books
FROM issue_status
JOIN employees
ON issue_status.issued_emp_id = employees.emp_id
GROUP BY emp_name
ORDER BY total_issued_books DESC
LIMIT 5;

--1) Laura Martinez	    6
--2) Michelle Ramirez	6
--3) Jessica Taylor 	4
--4) Emily Davis	    4
--5) Sarah Brown	    4

--------------------------------------------------------------------------------------------------------------

-- Which members issue the most books?


-- This query retrieves the top 5 members who have issued the most books.
-- It joins the 'issue_status' table with the 'members' table on the member ID.
-- The query counts the total number of books issued by each member and groups the results by member ID.
-- The results are ordered in descending order of the total issued books.
-- Finally, the query limits the output to the top 5 members with the highest number of issued books.
SELECT
    member_name,
    COUNT(issued_book_isbn) AS total_issued_books
FROM issue_status
JOIN members
ON issue_status.issued_member_id = members.member_id
GROUP BY member_id
ORDER BY total_issued_books DESC
LIMIT 5;


--1) Ivy Martinez  : 7
--2) Grace Taylor  : 6
--3) Jack Wilson   : 6
--4) Eve Brown     : 5
--5) Frank Thomas  : 4

--------------------------------------------------------------------------------------------------------------

--   How many members joined in the last years?


-- This query retrieves the total number of members who joined the library for each year.
-- It extracts the year from the 'reg_date' column using the YEAR() function and groups the data by year.
-- The COUNT(*) function is used to calculate the total number of members who joined in each year.
-- The results are ordered in descending order of the year to display the most recent years first.
SELECT
    YEAR(reg_date) AS year_joined,
    COUNT(*) AS total_members_joined_last_year
FROM members
GROUP BY year_joined
ORDER BY year_joined DESC;

-- 2024	 : 2
-- 2022	:  2
-- 2021	:  8

-------------------------------------------------------------------------------------

-- Which branch has the most employees?

-- This query retrieves the top 2 branches with the highest number of employees.
-- It performs the following steps:
-- 1. Joins the 'employees' table (aliased as 'e') with the 'branch' table (aliased as 'b') 
--    on the 'branch_id' column to associate employees with their respective branches.
-- 2. Groups the data by 'branch_id' and 'branch_address' to calculate the total number of employees per branch.
-- 3. Counts the number of employees ('emp_id') for each branch and assigns it as 'total_employees'.
-- 4. Orders the results in descending order of 'total_employees' to prioritize branches with more employees.
-- 5. Limits the output to the top 2 branches with the highest employee count.
SELECT 
    e.branch_id,
    b.branch_address,
    COUNT(e.emp_id) AS total_employees
FROM employees As e
JOIN branch As b
ON e.branch_id = b.branch_id
GROUP BY branch_id, branch_address
ORDER BY total_employees DESC
LIMIT 2;

-- 1) B001 : 5    branch_address :123 Main St
-- 2) B005 : 3   branch_address : 890 Maple St



--------------------------------------------------------------------------------------------------------------


-- Which book categories generate the most revenue?


-- This query calculates the total revenue generated from book rentals for each category.
-- It groups the data by the 'category' column and sums up the 'rental_price' for each group.
-- The results are then ordered in descending order of total revenue.
-- Finally, it limits the output to the top 5 categories with the highest total revenue.
SELECT 
    category,
    SUM(rental_price) AS total_revenue
FROM books
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 5;

--1) Dystopian	54.99
--2) History	49.50
--3) Fiction	48.47
--4) Classic	45.50
--5) Fantasy	36.49


--------------------------------------------------------------------------------------------------------------

-- Are there books never borrowed?

-- This query retrieves a list of books that are currently available in the library 
-- and have not been issued to any user. 
-- It selects the book title, category, and author from the 'books' table.
-- The query performs a LEFT JOIN between the 'books' table and the 'issue_status' table 
-- to identify books that do not have a matching record in the 'issue_status' table 
-- (i.e., books that have not been issued).
-- The condition `IST.issued_book_isbn IS NULL` ensures that only unissued books are included.
-- Additionally, the query filters for books with a status of 'yes', indicating they are available.
SELECT   
    B.book_title,
    B.category,
    B.author 
FROM books B
LEFT JOIN issue_status IST
ON B.isbn = IST.issued_book_isbn
WHERE IST.issued_book_isbn IS NULL
AND B.status ='yes'



----------------------------------------------------------------------------------------------------

-- What's the average salary by job role?

SELECT * FROM employees;

SELECT
    position,
    ROUND(AVG(salary), 0) AS average_salary
FROM employees
GROUP BY position
ORDER BY average_salary DESC;

--1) Librarian  :	55000
--2) Clerk	    : 53250
--3) Manager	  : 49000
--4) Assistant  : 47500


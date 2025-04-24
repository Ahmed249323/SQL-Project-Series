
-------------------------------------------------------------------------------------------------------------
-- ------------------------------ Project Title: Retail Sales Analysis SQL Project --------------------------
-- ---------------------------- -----------------------------------------------------------------------------


-- Description: This SQL project focuses on analyzing retail sales data to derive insights about sales performance,
--                                   customer behavior, and product trends. The analysis includes data cleaning, exploration,
 ---                                and visualization of key metrics such as total sales, customer demographics, and product performance.

CREATE DATABASE retail_sales;
USE retail_sales;

-- Create the retail_sales table

CREATE TABLE `sql - retail sales analysis_utf` (
  `ï»؟transactions_id` int DEFAULT NULL,
  `sale_date` text,
  `sale_time` text,
  `customer_id` double DEFAULT NULL,
  `gender` text,
  `age` int DEFAULT NULL,
  `category` text,
  `quantiy` int DEFAULT NULL,
  `price_per_unit` int DEFAULT NULL,
  `cogs` int DEFAULT NULL,
  `total_sale` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci


-- Rename the table to retail_sales
-- and modify the column types

RENAME TABLE  `sql - retail sales analysis_utf`  TO retail_sales;
ALTER TABLE retail_sales
MODIFY COLUMN sale_date DATE,
MODIFY COLUMN sale_time TIME;

ALTER TABLE retail_sales
RENAME COLUMN ï»؟transactions_id TO transactions_id;


-- DATA CLEANING
--- CHECK FOR NULL VALUES

SELECT * FROM retail_sales
WHERE 
        transactions_id IS NULL
        OR 
        sale_date IS NULL
        OR
        sale_time IS NULL
        OR
        gender IS NULL
        OR
        category IS NULL
        OR
        quantiy IS NULL
        OR
        cogs IS NULL
        OR
        total_sale IS NULL;

                                                            -------------------------------
                                                            ------ DATA EXPLORATION  ------
                                                            -------------------------------
---------------------------                                                        
---- Sales Performance ----                                                         
---------------------------

---- What are the total sales over time (monthly)?

SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month,
       SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY month
ORDER BY total_sales DESC;


--- Which product categories generate the highest sales or profits?

SELECT category, 
       SUM(total_sale) AS total_sales,
       SUM(cogs) AS total_cogs,
       SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;


--- What is the average sale amount per transaction?

SELECT AVG(total_sale) AS average_sale
FROM retail_sales;



--- What are the sales trends by time of day?

SELECT 
       CASE
            WHEN HOUR(sale_time) BETWEEN 6 AND 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(sale_time) BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
            END AS time_of_day,
        SUM(total_sale) AS total_sales      
FROM retail_sales
GROUP BY time_of_day
ORDER BY total_sales DESC;


--------------------------------
-------  Customer Insights -----
--------------------------------

--- Which gender spends more or makes more purchases?
SELECT  
    gender,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender
ORDER BY total_sales DESC;



--- What is the age distribution of customers, and how does it relate to their spending?
SELECT  
    CASE 
        WHEN AGE <=20 THEN 'Under 20'
        WHEN AGE BETWEEN 20 AND 30 THEN '20-29'
        WHEN AGE BETWEEN 31 AND 40 THEN '30-39'
        WHEN AGE BETWEEN 41 AND 50 THEN '40-49'
        WHEN AGE BETWEEN 51 AND 60 THEN '50-59'
        ELSE '60 and above'
    END AS age_group,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY age_group
ORDER BY total_sales DESC;



--- Are there loyal/high-value customers based on total sales per customer?

SELECT 
    customer_id ,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC;


--------------------------------------
-------  Product Analysis -----------
--------------------------------------

--- What’s the average quantity sold per category?

SELECT   
    category,
    AVG(quantiy) AS average_quantity
FROM retail_sales
GROUP BY category
ORDER BY average_quantity DESC;






--- Which categories have the highest markup (difference between price per unit and COGS)?
SELECT
    category,
    AVG(price_per_unit -cogs) AS avg_markup
FROM retail_sales
GROUP BY category
ORDER BY avg_markup DESC;




--- What’s the distribution of total sales across different categories?
SELECT 
    category,
    CONCAT(ROUND(SUM(total_sale) / (SELECT SUM(total_sale) FROM retail_sales) * 100, 2), '%') AS total_sales_percentage
FROM retail_sales
GROUP BY category
ORDER BY total_sales_percentage DESC;
---------------------------------------
-------   Temporal Patterns -----------
---------------------------------------



--- What are the peak sales days of the week?
SELECT 

    DATE_FORMAT(sale_date, '%W') AS DAY,
    COUNT(*) AS total_transactions,
    AVG(total_sale) AS Avg_sales
FROM retail_sales
GROUP BY DAY
ORDER BY Avg_sales DESC;



--- What are the peak sales hours?
SELECT 
    HOUR(sale_time) AS HOUR,
    COUNT(*) AS total_transactions,
    AVG(total_sale) AS Avg_sales
FROM retail_sales
GROUP BY HOUR
ORDER BY Avg_sales DESC;





-----------------------------------------
------- Optimization Opportunities ------
-----------------------------------------


---Are there categories where COGS is high relative to sales (low profit margins)?
SELECT 
    category,
    SUM(cogs) AS total_cogs,
    SUM(total_sale) AS total_sales,
    SUM(total_sale - cogs) AS profit,
    CONCAT(ROUND((SUM(total_sale - cogs) / SUM(total_sale)) * 100,2), '%') AS profit_margin_percentage
FROM retail_sales
GROUP BY category
ORDER BY profit_margin_percentage DESC;





--- Which times or categories show low sales and could benefit from promotions?

SELECT 
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales ASC;




SELECT 
    HOUR(sale_time) AS HOUR,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY HOUR
ORDER BY total_sales Asc;







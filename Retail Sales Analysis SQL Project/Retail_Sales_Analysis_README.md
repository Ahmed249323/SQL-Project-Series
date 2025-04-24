
# 🛒 Retail Sales Analysis
## 📘 Project Overview

- **Project Title**: Retail Sales Analysis  
- **Database**: `retail_sales`  
- **Project Type**: SQL Data Analysis  
- **Complexity Level**: Beginner to Intermediate  

This project provides a comprehensive analysis of retail sales data using SQL. It walks through the entire data analysis workflow—from database setup and data cleaning to advanced analytical queries—to uncover valuable business insights related to sales performance, customer behavior, and product trends.

---

## 🗃️ Database Structure

The analysis is based on a single main table:

```sql
CREATE TABLE retail_sales (
  transactions_id INT,
  sale_date DATE,
  sale_time TIME,
  customer_id DOUBLE,
  gender TEXT,
  age INT,
  category TEXT,
  quantiy INT,
  price_per_unit INT,
  cogs INT,
  total_sale INT
);
```

---

## 📊 Key Analysis Areas

### 1. Sales Performance Metrics
- Monthly sales trends
- Product category performance
- Average transaction value
- Time-of-day sales patterns

### 2. Customer Insights
- Spending by gender
- Age group analysis
- High-value customer identification

### 3. Product Analysis
- Category performance
- Profit margin analysis
- Sales distribution

### 4. Temporal Patterns
- Peak sales days
- Busiest hours
- Seasonal trends

### 5. Optimization Opportunities
- Low-margin categories
- Underperforming time slots
- Promotion opportunities

---

## 🧠 SQL Query Highlights

### 🔝 Top Performing Categories
```sql
SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC
LIMIT 5;
```

### 👥 Customer Age Distribution
```sql
SELECT  
  CASE  
    WHEN age <= 20 THEN 'Under 20'
    WHEN age <= 30 THEN '20-30'
    WHEN age <= 40 THEN '31-40'
    WHEN age <= 50 THEN '41-50'
    ELSE '50+'
  END AS age_group,
  COUNT(*) AS customers
FROM retail_sales
GROUP BY age_group;
```

### 📅 Daily Sales Trends
```sql
SELECT  
  DAYNAME(sale_date) AS day,
  AVG(total_sale) AS avg_sales
FROM retail_sales
GROUP BY day
ORDER BY avg_sales DESC;
```

---


## 🛠️ Implementation Guide

### Step 1: Setup
```sql
CREATE DATABASE retail_sales;
USE retail_sales;
```

### Step 2: Data Import
- Import your sales data into the `retail_sales` table.
- Verify data quality (e.g., NULL checks, data types).

### Step 3: Run Analysis
- Execute the provided SQL queries.
- Modify them as needed to address your specific business questions.

### Step 4: Visualization
- Export query results to your preferred BI tool (e.g., Power BI, Tableau).
- Create dashboards for key metrics and insights.

---

## 💡 Project Value

This SQL-based analysis enables retailers to:

- Identify top-performing products and categories
- Understand customer demographics and preferences
- Optimize staff allocation based on peak sales hours
- Refine promotional and marketing strategies
- Boost overall profitability through data-driven decisions

---

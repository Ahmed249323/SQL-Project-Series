# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. **gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | INT           | Surrogate key uniquely identifying each customer record (generated via `ROW_NUMBER()`).       |
| customer_id      | VARCHAR       | Unique customer identifier from CRM (`crm_cust_info.cst_id`).                                |
| customer_number  | VARCHAR       | Alphanumeric customer identifier from CRM (`crm_cust_info.cst_key`).                         |
| first_name       | VARCHAR       | Customer's first name (`crm_cust_info.cst_firstname`).                                       |
| last_name        | VARCHAR       | Customer's last name (`crm_cust_info.cst_lastname`).                                         |
| country          | VARCHAR       | Customer's country from ERP (`erp_loc_a101.CNTRY`).                                          |
| marital_status   | VARCHAR       | Marital status from CRM (`crm_cust_info.cst_marital_status`).                                |
| gender           | VARCHAR       | Prioritizes CRM value; falls back to ERP or `n/a` (`crm_cust_info.cst_gndr`, `erp_cust_az12.GEN`). |
| birthdate        | DATE          | Birthdate from ERP (`erp_cust_az12.BDATE`).                                                  |
| create_date      | DATE          | Customer account creation date (`crm_cust_info.cst_create_date`).                            |

---

### 2. **gold.dim_products**
- **Purpose:** Provides product details with categories, subcategories, and maintenance status.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key      | INT           | Surrogate key (generated via `ROW_NUMBER()`).                                                 |
| product_id       | VARCHAR       | Product ID from CRM (`crm_prd_info.prd_id`).                                                 |
| product_number   | VARCHAR       | Product identifier from CRM (`crm_prd_info.prd_key`).                                         |
| product_name     | VARCHAR       | Product name (`crm_prd_info.prd_nm`).                                                        |
| category_id      | VARCHAR       | Category ID (`crm_prd_info.cat_id`).                                                         |
| category         | VARCHAR       | Product category from ERP (`erp_px_cat_g1v2.cat`).                                           |
| subcategory      | VARCHAR       | Product subcategory from ERP (`erp_px_cat_g1v2.subcat`).                                     |
| maintenance      | VARCHAR       | Maintenance status (`Yes`/`No`) from ERP (`erp_px_cat_g1v2.maintenance`).                    |
| product_line     | VARCHAR       | Product line from CRM (`crm_prd_info.prd_line`).                                             |
| cost             | DECIMAL       | Product cost from CRM (`crm_prd_info.prd_cost`).                                             |
| start_date       | DATE          | Product activation date (`crm_prd_info.prd_start_dt`).                                       |

---

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data linked to product and customer dimensions.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | VARCHAR       | Unique sales order ID (`crm_sales_details.sls_ord_num`).                                     |
| product_key     | INT           | Foreign key to `dim_products` (linked via `sls_prd_key = product_number`).                   |
| customer_key    | INT           | Foreign key to `dim_customers` (linked via `sls_cust_id = customer_id`).                     |
| order_date      | DATE          | Order date (`crm_sales_details.sls_order_dt`).                                               |
| shipping_date   | DATE          | Shipping date (`crm_sales_details.sls_ship_dt`).                                             |
| due_date        | DATE          | Due date (`crm_sales_details.sls_due_dt`).                                                   |
| sales_amount    | DECIMAL       | Total sales amount (`crm_sales_details.sls_sales`).                                          |
| quantity        | INT           | Quantity sold (`crm_sales_details.sls_quantity`).                                            |
| price           | DECIMAL       | Price per unit (`crm_sales_details.sls_price`).                                              |

---

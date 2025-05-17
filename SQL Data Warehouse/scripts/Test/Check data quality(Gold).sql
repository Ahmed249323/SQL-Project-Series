--------------------------------------------------------------------------------
---------------------------------chack DIM_CUSTOMER ------------------------------
--------------------------------------------------------------------------------
-- Create a view for the customer dimension, joining CRM and ERP sources and normalizing gender and birthdate
CREATE VIEW  gold.dim_customers AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_number, 
        ci.cst_firstname AS first_name,
        ci.cst_lastname  AS last_name,
        ci.cst_marital_status  AS marital_status,
        el.CNTRY AS country,
        CASE 
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
            ELSE COALESCE(ec.GEN, 'n/a') 
        END AS gender,
        ec.BDATE AS birthdate,
        cst_create_date AS create_date
    FROM SILVER.CRM_CUST_INFO ci    
    LEFT JOIN  SILVER.ERP_CUST_AZ12 ec 
    ON ci.cst_key = ec.cid
    LEFT JOIN SILVER.ERP_LOC_A101 el
    ON ec.cid = el.cid
GO

-- Check for duplicate customer IDs after join
-- This query identifies any customer IDs that appear more than once in the joined CRM and ERP customer data.
-- Duplicates may indicate data integration issues or non-unique business keys, which should be resolved for a reliable dimension table.
SELECT cst_id,
        COUNT(*)
FROM
(SELECT ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    cst_create_date,
    ec.BDATE,
    ec.GEN,
    el.CNTRY
FROM SILVER.CRM_CUST_INFO ci    
LEFT JOIN  SILVER.ERP_CUST_AZ12 ec 
ON ci.cst_key = ec.cid
LEFT JOIN SILVER.ERP_LOC_A101 el
ON ec.cid = el.cid
) t  GROUP BY t.cst_id
HAVING COUNT(*) > 1

-- Show distinct gender values from CRM and ERP, and the normalized result
-- This query helps validate gender harmonization logic by showing all unique combinations of gender values
-- from both CRM and ERP sources, as well as the resulting value after applying the normalization rule.
-- Useful for spotting unexpected or inconsistent gender codes in the source data.
SELECT DISTINCT
    ci.cst_gndr,
    ec.GEN,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr ELSE COALESCE(ec.GEN, 'n/a') END AS cst_gndr
FROM SILVER.CRM_CUST_INFO ci    
LEFT JOIN  SILVER.ERP_CUST_AZ12 ec 
ON ci.cst_key = ec.cid
LEFT JOIN SILVER.ERP_LOC_A101 el
ON ec.cid = el.cid
ORDER BY 1,2

-- Show all distinct gender values in the gold customer dimension
-- This query lists all unique gender values present in the gold.dim_customers view after transformation.
-- It is useful for verifying that the gender normalization logic is working as intended and that no unexpected values remain.
SELECT DISTINCT  gender FROM  gold.dim_customers

-----------------------------------------------------------------------------------
---------------------------------chack DIM_PRDOUCT ------------------------------
--------------------------------------------------------------------------------

-- Show all product info from CRM and ERP sources
-- These queries display the raw product and category data from the silver layer, allowing you to inspect the source records
-- before they are joined and transformed into the product dimension. Useful for troubleshooting and validation.
SELECT * FROM silver.crm_prd_info
SELECT * FROM silver.erp_px_cat_g1v2

-- Check for duplicate product keys where end date is NULL (active products)
SELECT prd_key , COUNT(*) FROM 
(SELECT cp.prd_id,
        cp.prd_key,
        cp.cat_id ,
        cp.prd_nm,
        ep.cat,
        ep.subcat,
        ep.maintenance,
        cp.prd_cost,
        prd_line,
        cp.prd_start_dt,
        cp.prd_end_dt
FROM  silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ep
ON cp.cat_id = ep.id
WHERE cp.prd_end_dt IS NULL) T  GROUP BY prd_key
HAVING COUNT(*) > 1
GO

-- Create a view for the product dimension, joining CRM and ERP product/category info, only for active products
CREATE VIEW gold.dim_products AS
SELECT 
        ROW_NUMBER() OVER(ORDER BY cp.prd_start_dt , cp.prd_key) AS product_key, -- Surrogate key for product dimension
        cp.prd_id As product_id, -- Source product ID
        cp.prd_key AS product_number, -- Business/product number
        cp.prd_nm AS product_name, -- Product name
        cp.cat_id  AS category_id, -- Category ID (foreign key)
        ep.cat AS category, -- Category name from ERP
        ep.subcat AS  subcategory , -- Subcategory from ERP
        ep.maintenance, -- Maintenance type/category from ERP
        prd_line AS product_line, -- Product line
        cp.prd_cost AS cost , -- Product cost
        cp.prd_start_dt AS start_date -- Product start date (active from)
FROM  silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ep
ON cp.cat_id = ep.id -- Join to get category and maintenance info
WHERE cp.prd_end_dt IS NULL -- Filter out all historical data (only active products)
GO

-- Show all records in the gold product dimension
SELECT * FROM GOLD.DIM_PRODUCTS
GO

-- Create a fact sales view joining sales details with product and customer dimensions
CREATE VIEW GOLD.FACT_SALES AS
    SELECT sls_ord_num AS order_number,
            dp.product_key,
            dc.customer_key,
            sls_order_dt AS order_date,
            sls_ship_dt AS  shipping_date,
            sls_due_dt AS due_date,
            sls_sales AS sales_amount,
            sls_quantity AS quantity,
            sls_price AS price
    FROM SILVER.crm_sales_details sd 
    LEFT JOIN GOLD.DIM_PRODUCTS dp
    ON sd.sls_prd_key = dp.product_number
    LEFT JOIN GOLD.DIM_CUSTOMERS dc
    ON sd.sls_cust_id = dc.customer_id
GO

-- Show all records in the fact sales table, joined with product and customer dimensions, only where product_id is not null
SELECT *
FROM GOLD.FACT_SALES
LEFT JOIN GOLD.DIM_PRODUCTS dp
ON FACT_SALES.product_key = dp.product_key
LEFT JOIN GOLD.DIM_CUSTOMERS dc
ON FACT_SALES.customer_key = dc.customer_key
WHERE dp.product_id is not null

--------------------------------------------------------------------------------------------------
----------------------------------------- check crm_cust_info ------------------------------------
--------------------------------------------------------------------------------------------------

-- Retrieve customer IDs and their counts, showing only duplicates or NULLs.
SELECT
    CST_ID, 
  COUNT(*)
FROM bronze.crm_cust_info
GROUP BY CST_ID
HAVING COUNT(*) > 1 OR CST_ID IS NULL ;
GO 

------------------

-- Count rows where cst_lastname has leading or trailing spaces
SELECT COUNT(*) FROM BRONZE.CRM_CUST_INFO
WHERE cst_lastname != TRIM(cst_lastname);

-- Count rows where cst_firstname has leading or trailing spaces
GO
SELECT COUNT(*) FROM BRONZE.CRM_CUST_INFO
WHERE  cst_firstname !=TRIM(cst_firstname)

--------    --------
-- Retrieve a distinct list of customer genders (cst_gndr) 
-- from the CRM_CUST_INFO table in the Bronze schema.
SELECT DISTINCT cst_gndr
FROM bronze.CRM_CUST_INFO

-- Retrieve a distinct list of customer marital statuses 
-- from the CRM_CUST_INFO table in the Bronze schema.
SELECT DISTINCT cst_marital_status
FROM bronze.CRM_CUST_INFO

--------------------------------------------------------------------------------------------------
----------------------------------------- check crm_prd_info --------------------------------------
--------------------------------------------------------------------------------------------------

-- Identify duplicate or NULL PRD_ID values in the crm_prd_info table.
SELECT PRD_ID,
  COUNT(*)
FROM BRONZE.crm_prd_info
GROUP BY PRD_ID
HAVING COUNT(*) > 1 OR PRD_ID IS NULL;

-- Check for leading or trailing spaces in PRD_NM
SELECT COUNT(*) FROM BRONZE.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
GO

-- Check for negative or NULL values in PRD_COST
SELECT COUNT(*) FROM BRONZE.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
GO

-- Retrieve a distinct list of product lines (prd_line) from crm_prd_info
SELECT DISTINCT prd_line
FROM BRONZE.crm_prd_info

-- Find products where start date is after end date
SELECT prd_start_dt,
       prd_end_dt
FROM BRONZE.crm_prd_info
WHERE prd_start_dt > prd_end_dt

-- Show product date ranges and calculate previous product's end date for given keys
SELECT prd_id,
        prd_key,
        prd_nm,
        prd_start_dt,
        prd_end_dt,
        DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key in('AC-HE-HL-U509-R' ,'AC-HE-HL-U509')

--------------------------------------------------------------------------------------------------
----------------------------------------- check CRM_SALES_DETAILS -----------------------------------
--------------------------------------------------------------------------------------------------

-- Retrieve all sales details records
SELECT *
FROM BRONZE.CRM_SALES_DETAILS

-- Count sales orders with leading or trailing spaces in order number
SELECT COUNT(*)
FROM bronze.crm_sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num

-- Find sales orders with invalid order date (not 8 digits, out of range, or zero)
SELECT NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0
OR LEN(sls_order_dt) != 8
OR sls_order_dt >'20500101'
OR sls_order_dt < '19000101'  

-- Find sales orders with invalid ship date (not 8 digits, out of range, or zero)
SELECT NULLIF(sls_ship_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <=0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt >'20500101'
OR sls_ship_dt < '19000101'  

-- Find sales orders with invalid due date (not 8 digits, out of range, or zero)
SELECT NULLIF(sls_due_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <=0
OR LEN(sls_due_dt) != 8
OR sls_due_dt >'20500101'
OR sls_due_dt < '19000101'  

-- Find sales records with inconsistent date relationships (order > ship/due, ship > due)
SELECT *
FROM bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or
       sls_order_dt > sls_due_dt or
       sls_ship_dt > sls_due_dt

-- Find sales records with non-positive sales, quantity, or price
SELECT  sls_sales,
        sls_quantity,
        sls_price
FROM bronze.crm_sales_details  
WHERE  -- sls_sales != sls_quantity * sls_price
         sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
        -- OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales , sls_quantity , sls_price

--------------------------------------------------------------------------------------------------
----------------------------------------- check ERP_CUST_AZ12 ------------------------------------
--------------------------------------------------------------------------------------------------

-- Retrieve all records from ERP_CUST_AZ12
SELECT * FROM BRONZE.ERP_CUST_AZ12
-- Retrieve all records from CRM_CUST_INFO for comparison
SELECT * FROM BRONZE.CRM_CUST_INFO

-- Count records in ERP_CUST_AZ12 with leading or trailing spaces in CID
SELECT COUNT(*)
FROM bronze.erp_cust_az12
WHERE TRIM(CID) != CID

-- Find duplicate or NULL CIDs in ERP_CUST_AZ12
SELECT CID ,
      COUNT(*)
FROM bronze.ERP_CUST_AZ12
GROUP BY CID
HAVING COUNT(*) > 1 OR CID IS NULL;

-- Retrieve all records with normalized CID, BDATE, and GEN fields
SELECT * ,
    CASE WHEN CID  LIKE  'NAS%'  THEN SUBSTRING(CID,4,LEN(CID))
      ELSE CID 
    END AS CID,
    CASE WHEN BDATE > GETDATE() THEN NULL
      ELSE BDATE
    END AS BDATE
    ,
    CASE 
      WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
      WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
      ELSE 'n/a'
    END AS GEN
FROM BRONZE.ERP_CUST_AZ12

--------------------------------------------------------------------------------------------------
----------------------------------------- check ERP_LOC_A101 ------------------------------------
--------------------------------------------------------------------------------------------------

-- Retrieve all records from ERP_LOC_A101
SELECT * FROM BRONZE.ERP_LOC_A101

-- Count records in ERP_LOC_A101 with leading or trailing spaces in CID
SELECT COUNT(*)
FROM bronze.ERP_LOC_A101
WHERE TRIM(CID) != CID

-- Find duplicate or NULL CIDs in ERP_CUST_AZ12 (possible cross-check)
SELECT CID ,
      COUNT(*)
FROM bronze.ERP_CUST_AZ12
GROUP BY CID
HAVING COUNT(*) > 1 OR CID IS NULL;

-- Retrieve a distinct list of countries from ERP_LOC_A101
SELECT DISTINCT CNTRY
FROM bronze.ERP_LOC_A101

-- Retrieve all records with normalized country names
SELECT *,
      -- REPLACE(CID ,'-','') AS CID ,
      CASE 
        WHEN TRIM(CNTRY) IN('US', 'USA')  THEN 'United States'
        WHEN TRIM(CNTRY) LIKE  'DE' THEN 'Germany'
        WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = ''  THEN 'n/a'
        ELSE TRIM(CNTRY)
      END AS CNTRY
FROM bronze.ERP_LOC_A101 

----------------------------------------------------------------------------------
----------------------------------------- Load ERP_PX_CAT_G1V2 -------------------
----------------------------------------------------------------------------------

-- Retrieve all records from ERP_PX_CAT_G1V2
SELECT * FROM bronze.ERP_PX_CAT_G1V2
-- Retrieve all records from SILVER.crm_prd_info for comparison
SELECT * FROM  SILVER.crm_prd_info

-- Count records in ERP_PX_CAT_G1V2 with leading or trailing spaces in ID
SELECT COUNT(*)
FROM bronze.ERP_PX_CAT_G1V2
WHERE TRIM(ID) != ID

-- Find duplicate or NULL IDs in ERP_PX_CAT_G1V2
SELECT ID ,
      COUNT(*)
FROM bronze.ERP_PX_CAT_G1V2
GROUP BY ID
HAVING COUNT(*) > 1 OR ID IS NULL;

-- Retrieve a distinct list of categories from ERP_PX_CAT_G1V2
SELECT DISTINCT CAT
FROM bronze.ERP_PX_CAT_G1V2

-- Retrieve a distinct list of subcategories from ERP_PX_CAT_G1V2
SELECT DISTINCT SUBCAT
FROM bronze.ERP_PX_CAT_G1V2

-- Retrieve a distinct list of maintenance types from ERP_PX_CAT_G1V2
SELECT DISTINCT MAINTENANCE
FROM bronze.ERP_PX_CAT_G1V2
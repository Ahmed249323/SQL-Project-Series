-- Loads and transforms data from Bronze to Silver layer tables.
-- Truncates Silver tables, inserts cleaned/transformed data, and logs progress.
-- Handles errors and prints batch timing.
CREATE OR ALTER PROCEDURE SILVER.LOAD_SILVER AS
BEGIN
    DECLARE @START_TIME DATETIME, @END_TIME DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY

            SET @batch_start_time = GETDATE()
            PRINT('=======  Loading Silver Layer   =======');

            PRINT('----------- Loading CRM Tables ----------');

            ----------------------------------------------------------------------------------
            -----------------------------------------Load CRM_CUST_INFO ----------------------
            ---------------------------------------------------------------------------------- 
            PRINT('>> Truncating and loading SILVER.CRM_CUST_INFO')
            TRUNCATE TABLE SILVER.CRM_CUST_INFO
            SET @START_TIME = GETDATE();
            INSERT INTO SILVER.CRM_CUST_INFO (
                cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date
            )
            SELECT
            CST_ID ,
            CST_KEY ,
            TRIM(CST_FIRSTNAME) AS CST_FIRSTNAME ,
            TRIM(CST_LASTNAME) AS CST_LASTNAME ,
            CASE 
                WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END CST_MARITAL_STATUS,
            CASE 
                WHEN UPPER(TRIM(CST_GNDR)) ='M'  THEN 'Male'
                WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END CST_GNDR,   
            CST_CREATE_DATE
            FROM 
            (SELECT *,
                ROW_NUMBER() OVER(PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS FLAG_LAST
            FROM bronze.CRM_CUST_INFO
            WHERE CST_ID IS NOT NULL ) 
            AS SubQuery
            WHERE FLAG_LAST = 1

            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');



            ----------------------------------------------------------------------------------
            -----------------------------------------Load crm_prd_info ----------------------
            ----------------------------------------------------------------------------------
            PRINT('>> Truncating and loading SILVER.CRM_PRD_INFO')
            TRUNCATE TABLE SILVER.CRM_PRD_INFO
            SET @START_TIME = GETDATE();
            INSERT INTO SILVER.CRM_PRD_INFO(
                prd_id, cat_id, prd_key,prd_nm, prd_cost,prd_line,prd_start_dt,prd_end_dt
            )
            SELECT 
                prd_id,
                REPLACE(SUBSTRING(prd_key,1,5),'-','_')AS cat_id,
                SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
                prd_nm,
                ISNULL(prd_cost,0) AS  prd_cost,
                CASE UPPER(TRIM(prd_line))
                    WHEN   'M' THEN 'Mountain'
                    WHEN   'R' THEN 'Road'
                    WHEN   'S' THEN 'Other Sales'
                    WHEN   'T' THEN 'Touring'
                    ELSE 'n/a'
                END AS prd_line,
                CAST(prd_start_dt AS DATE) AS prd_start_dt,
                CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
            FROM bronze.CRM_PRD_INFO

            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');





            ----------------------------------------------------------------------------------
            -----------------------------------------Load sales_details ----------------------
            ----------------------------------------------------------------------------------
            PRINT('>> Truncating and loading SILVER.CRM_SALES_DETAILS')
            TRUNCATE TABLE SILVER.CRM_SALES_DETAILS
            SET @START_TIME = GETDATE();
            INSERT INTO SILVER.CRM_SALES_DETAILS(
                sls_ord_num , sls_prd_key , sls_cust_id , sls_order_dt , sls_ship_dt , sls_due_dt , sls_sales, sls_quantity, sls_price
            )
            SELECT sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                CASE  WHEN sls_order_dt <=0  OR LEN(sls_order_dt )!= 8 THEN NULL
                    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
                END AS sls_order_dt ,
                CASE  WHEN sls_ship_dt <=0  OR LEN(sls_ship_dt )!= 8 THEN NULL
                    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
                END AS sls_ship_dt,
                CASE  WHEN sls_due_dt <=0  OR LEN(sls_due_dt )!= 8 THEN NULL
                    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
                END AS sls_due_dt,
                CASE  WHEN sls_sales IS NULL OR sls_sales <=0  OR sls_sales != sls_quantity * ABS(sls_price)
                        THEN sls_quantity * ABS(sls_price)
                        ELSE sls_sales
                END AS sls_sales ,
                sls_quantity,
                CASE WHEN  sls_price IS NULL OR sls_price<=0 
                    THEN sls_sales / NULLIF(sls_quantity,0)
                    ELSE sls_price
                END AS sls_price
            FROM bronze.CRM_SALES_DETAILS

            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

            ----------------------------------------------------------------------------------
            ----------------------------------------- Load erp_cust_az12 ---------------------
            ----------------------------------------------------------------------------------

            PRINT('>> Truncating and loading SILVER.ERP_CUST_AZ12')
            TRUNCATE TABLE SILVER.ERP_CUST_AZ12
            SET @START_TIME = GETDATE();

            INSERT INTO SILVER.ERP_CUST_AZ12 (CID, BDATE, GEN)
            SELECT 
                CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID , 4 , LEN(CID))
                    ELSE    CID
                END AS CID
                ,
                CASE WHEN BDATE > GETDATE() THEN NULL
                    ELSE BDATE
                END AS BDATE
                ,
                CASE 
                    WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
                    WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
                    ELSE 'n/a'
                END AS GEN
            FROM bronze.ERP_CUST_AZ12

            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

            ----------------------------------------------------------------------------------
            ----------------------------------------- Load ERP_LOC_A101 ---------------------
            ----------------------------------------------------------------------------------
            PRINT('>> Truncating and loading SILVER.ERP_LOC_A101')
            TRUNCATE TABLE SILVER.ERP_LOC_A101
            SET @START_TIME = GETDATE();

            INSERT INTO silver.ERP_LOC_A101 (CID, CNTRY)
            SELECT  REPLACE(CID ,'-','') AS CID,
                    CASE 
                        WHEN TRIM(CNTRY) IN('US', 'USA')  THEN 'United States'
                        WHEN TRIM(CNTRY) LIKE  'DE' THEN 'Germany'
                        WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = ''  THEN 'n/a'
                        ELSE TRIM(CNTRY)
                    END AS CNTRY
            FROM bronze.ERP_LOC_A101

            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

            ----------------------------------------------------------------------------------
            ----------------------------------------- Load ERP_PX_CAT_G1V2 -------------------
            ----------------------------------------------------------------------------------
            PRINT('>> Truncating and loading SILVER.ERP_PX_CAT_G1V2')
            TRUNCATE TABLE SILVER.ERP_PX_CAT_G1V2
            SET @START_TIME = GETDATE();

            INSERT INTO SILVER.ERP_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
            SELECT TRIM(ID)AS ID,
                TRIM(CAT) AS CAT,
                TRIM(SUBCAT) AS SUBCAT,
                TRIM(MAINTENANCE) AS MAINTENANCE
            FROM bronze.ERP_PX_CAT_G1V2
            SET @END_TIME =GETDATE();
            PRINT('Time taken: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

    SET @batch_end_time = GETDATE()
    PRINT('Loading for silver layer completed');
    PRINT('Batch start time: ' + CAST(@batch_start_time AS NVARCHAR));
    PRINT('Batch end time: ' + CAST(@batch_end_time AS NVARCHAR));
    PRINT('Batch duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds');

    END TRY
    BEGIN CATCH 
            PRINT('ERROR  OCCURED DURING LOADING SILVER LAYER');
            PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
            PRINT('ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
            PRINT('ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR));
    END CATCH

END

EXEC silver.LOAD_SILVER
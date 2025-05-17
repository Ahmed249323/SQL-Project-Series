
CREATE OR ALTER PROCEDURE BRONZE.LOAD_BRONZE_DATA AS
BEGIN
    DECLARE @START_TIME DATETIME, @END_TIME DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY

        SET @batch_start_time = GETDATE();
        -- Start loading process
        PRINT('=======  Loading Bronze Layer   =======');

        -- Load CRM tables
        PRINT('----------- Loading CRM Tables ----------');

        -- Load CRM_CUST_INFO
        PRINT('>> Truncating and loading BRONZE.CRM_CUST_INFO');
        TRUNCATE TABLE BRONZE.CRM_CUST_INFO;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.CRM_CUST_INFO
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_crm\cust_info.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

        -- Load CRM_PRD_INFO
        PRINT('>> Truncating and loading BRONZE.CRM_PRD_INFO');
        TRUNCATE TABLE BRONZE.CRM_PRD_INFO;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.CRM_PRD_INFO
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_crm\prd_info.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

        -- Load CRM_SALES_DETAILS
        PRINT('>> Truncating and loading BRONZE.crm_sales_details');
        TRUNCATE TABLE BRONZE.crm_sales_details;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.crm_sales_details
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_crm\sales_details.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

        -- Load ERP tables
        PRINT('----------- Loading ERP Tables ----------');

        -- Load ERP_CUST_AZ12
        PRINT('>> Truncating and loading BRONZE.ERP_CUST_AZ12');
        TRUNCATE TABLE BRONZE.ERP_CUST_AZ12;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.ERP_CUST_AZ12
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

        -- Load ERP_LOC_A101
        PRINT('>> Truncating and loading BRONZE.ERP_LOC_A101');
        TRUNCATE TABLE BRONZE.ERP_LOC_A101;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.ERP_LOC_A101
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_erp\LOC_A101.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');

        -- Load ERP_PX_CAT_G1V2
        PRINT('>> Truncating and loading BRONZE.ERP_PX_CAT_G1V2');
        TRUNCATE TABLE BRONZE.ERP_PX_CAT_G1V2;
        SET @START_TIME = GETDATE();
        BULK INSERT BRONZE.ERP_PX_CAT_G1V2
        FROM 'D:\SQL Project\SQL Data Warehouse\Dataset\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW=2, ROWTERMINATOR='\n', FIELDTERMINATOR=',', TABLOCK);
        SET @END_TIME = GETDATE();
        PRINT('>> Duration: ' + CAST(DATEDIFF(SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' seconds');
        SET @batch_end_time = GETDATE();
        PRINT('Loading for bronze layer completed');
        PRINT('>>    Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds');

    END TRY   
    BEGIN CATCH 
            PRINT('ERROR  OCCURED DURING LOADING BRONZE LAYER');
            PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
            PRINT('ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
            PRINT('ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR));
    END CATCH
END
GO
 EXEC BRONZE.LOAD_BRONZE_DATA;
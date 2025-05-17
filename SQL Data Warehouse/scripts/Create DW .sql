USE Master ;
-- Create DataWarehouse database
-- This script creates a data warehouse database named DATA_WAREHOUSE.
CREATE DATABASE DATA_WAREHOUSE;
GO
USE DATA_WAREHOUSE;
GO
-- This script creates a data warehouse with three schemas: BRONZE, SILVER, and GOLD.
CREATE SCHEMA BRONZE;
GO 
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO

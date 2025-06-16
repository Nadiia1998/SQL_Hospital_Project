/*
=============================================================
Database and Schema Initialization Script
=============================================================
Description:
    This script initializes a new database named 'DataWarehouse'. 
    If a database with this name already exists, it will be dropped and recreated. 
    After creating the database, the script also sets up three schemas: 'bronze', 'silver', and 'gold'.

IMPORTANT:
    Executing this script will permanently delete the existing 'DataWarehouse' database, 
    including all its data. Use with extreme caution and ensure all necessary backups 
    are in place before proceeding.
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name='HospitalWatehouseAnalysys')
BEGIN
	ALTER DATABASE HospitalWatehouseAnalysys SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HospitalWatehouseAnalysys;
END;
GO



CREATE DATABASE HospitalWatehouseAnalysys;
GO

USE HospitalWatehouseAnalysys;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

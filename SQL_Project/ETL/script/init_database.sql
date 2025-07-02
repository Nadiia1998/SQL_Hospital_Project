/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'HospitalWarehouseAnalysys' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additional its create table
	
WARNING:
    Running this script will drop the entire 'HospitalWarehouseAnalysys' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name='HospitalWarehouseAnalysys')
BEGIN
	ALTER DATABASE HospitalWarehouseAnalysys SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HospitalWarehouseAnalysys;
END;
GO



CREATE DATABASE HospitalWarehouseAnalysys;
GO

USE HospitalWarehouseAnalysys;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

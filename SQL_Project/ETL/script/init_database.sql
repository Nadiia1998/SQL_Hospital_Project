/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'HospitalWatehouseAnalysys' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additional its create table
	
WARNING:
    Running this script will drop the entire 'HospitalWatehouseAnalysys' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
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

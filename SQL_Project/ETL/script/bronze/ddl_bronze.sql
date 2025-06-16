/*
=============================================================
Bronze Layer DDL Script
=============================================================
Description:
    This script defines the structure of the Bronze layer within the 'DataWarehouse' database.
    The Bronze layer serves as the raw data ingestion layer. It stores data in its original, 
    untransformed state from csv files.

    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
*/
IF OBJECT_ID('bronze.encounters','U') IS NOT NULL
	DROP table bronze.encounters;
GO

CREATE TABLE bronze.encounters (
	id				NVARCHAR(50),
	start_datetime			DATETIME,
	end_datetime			DATETIME,
	patient				NVARCHAR(50),
	organization			NVARCHAR(50),
	payer				NVARCHAR(50),
	encounter_class			NVARCHAR(50),
	code				INT,
	type_encounter			NVARCHAR(100),
	base_encounter_cost		FLOAT,
	total_claim_cost		FLOAT,
	payer_coverage			FLOAT,
	reason_code			BIGINT,
	reason_description		NVARCHAR(100)
);
GO

IF OBJECT_ID('bronze.patients','U') IS NOT NULL
	DROP TABLE bronze.patients;
GO

CREATE TABLE bronze.patients(
	id			NVARCHAR(50),
	birth_date		DATE,
	death_date		DATE,
	prefix			NVARCHAR(50),
	first_name		NVARCHAR(50),
	last_name		NVARCHAR(50),
	suffix			NVARCHAR(50),
	maiden			NVARCHAR(50),
	marital			NVARCHAR(50),
	race			NVARCHAR(50),
	ethnicity		NVARCHAR(50),
	gender			NVARCHAR(50),
	birth_place		NVARCHAR(100),
	address			NVARCHAR(50),
	city			NVARCHAR(50),
	state			NVARCHAR(50),
	county			NVARCHAR(50),	
	zip			INT,
	lat			FLOAT,
	lon			FLOAT
)

IF OBJECT_ID('bronze.payers','U') IS NOT NULL
	DROP TABLE bronze.payers;
GO

CREATE TABLE bronze.payers(
	id				NVARCHAR(50),
	name				NVARCHAR(50),
	address				NVARCHAR(50),	
	city				NVARCHAR(50),
	state_headquartered		NVARCHAR(50),
	zip				INT,
	phone				NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.procedures_table','U') IS NOT NULL
	DROP TABLE bronze.procedures_table;
GO

CREATE TABLE bronze.procedures_table(
	start_datetime			DATETIME,
	stop_datetime			DATETIME,
	patient				NVARCHAR(50),
	encounter			NVARCHAR(50),
	code				NVARCHAR(50),
	procedure_description		NVARCHAR(200),
	base_cost			INT,
	reason_code			INT,
	reason_description		NVARCHAR(100)
);
GO

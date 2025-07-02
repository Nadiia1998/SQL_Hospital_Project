/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Purpose:
    This script defines the structure of tables in the 'silver' schema by 
    creating them. If the tables already exist, they will be dropped first.
    Run this script to reset and reinitialize the DDL structure for the 
    corresponding 'bronze' tables.
===============================================================================
*/


IF OBJECT_ID('silver.encounters','U') IS NOT NULL
	DROP table silver.encounters;
GO

CREATE TABLE silver.encounters (
	id						        NVARCHAR(50),
	start_datetime			  DATETIME,
	end_datetime		    	DATETIME,
	patient					      NVARCHAR(50),
	organization		    	NVARCHAR(50),
	payer				        	NVARCHAR(50),
	encounter_class		   	NVARCHAR(50),
	code				         	INT,
	type_encounter		  	NVARCHAR(100),
	base_encounter_cost		FLOAT,
	total_claim_cost	  	FLOAT,
	payer_coverage		  	FLOAT,
	reason_code			    	NVARCHAR(50),
	reason_description		NVARCHAR(100),
	dwh_create_date		  	DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.patients','U') IS NOT NULL
	DROP TABLE silver.patients;
GO

CREATE TABLE silver.patients(
	id			        	NVARCHAR(50),
	birth_date	    	DATE,
	death_date	  	  DATE,
	prefix		    	  NVARCHAR(50),
	first_name	  	  NVARCHAR(50),
	last_name	    	  NVARCHAR(50),
	maiden			      NVARCHAR(50),
	marital		    	  NVARCHAR(50),
	race		      	  NVARCHAR(50),
	ethnicity	    	  NVARCHAR(50),
	gender		    	  NVARCHAR(50),
	birth_place  		  NVARCHAR(100),
	address			      NVARCHAR(50),
	city		      	  NVARCHAR(50),
	state		      	  NVARCHAR(50),
	county	     		  NVARCHAR(50),	
	zip			      	  NVARCHAR(50),
	lat			      	  FLOAT,
	lon			        	FLOAT,
	dwh_create_date  	DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID('silver.payers','U') IS NOT NULL
	DROP TABLE silver.payers;
GO

CREATE TABLE silver.payers(
	id				          	NVARCHAR(50),
	name			          	NVARCHAR(50),
	address		        		NVARCHAR(50),	
	city			          	NVARCHAR(50),
	state_headquartered  	NVARCHAR(50),
	zip				          	INT,
	phone			          	NVARCHAR(50),
	dwh_create_date		    DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.procedures_table','U') IS NOT NULL
	DROP TABLE silver.procedures_table;
GO

CREATE TABLE silver.procedures_table(
	start_datetime		    	DATETIME,
	stop_datetime	      		DATETIME,
	patient				        	NVARCHAR(50),
	encounter			         	NVARCHAR(50),
	code				          	NVARCHAR(50),
	procedure_description  	NVARCHAR(200),
	base_cost			         	INT,
	reason_code			       	NVARCHAR(50),
	reason_description  		NVARCHAR(100),
	dwh_create_date			     DATETIME2 DEFAULT GETDATE()
);
GO

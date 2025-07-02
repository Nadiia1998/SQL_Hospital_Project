--------------------------------
/*
===============================================================================
Data Quality Checks bronze_layer
===============================================================================
Purpose:
    This script executes a series of data quality validations on the 'silver' layer 
    to ensure data integrity, accuracy, and standardization. The checks include:
    - Detection of null or duplicate values in primary key columns.
    - Identification of leading/trailing spaces in string fields.
    - Verification of consistent and standardized data formats.
    - Validation of logical date sequences and ranges.
    - Cross-field consistency checks.

Usage Guidelines:
    - Execute this script after loading data into the Silver Layer.
    - Investigate any anomalies detected and take corrective actions as needed.
*/


----------------------------------
--Checking 'bronze.encounters' table
----------------------------------
  EXEC bronze.load_bronze

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT  id,COUNT(*)
FROM bronze.encounters
GROUP BY id
HAVING COUNT(*)>1 OR id IS NULL


--Checking MIN and MAX date for 'start_datetime'
SELECT MIN(start_datetime) as min_date,MAX(start_datetime) as max_date
FROM bronze.encounters

--Checking MIN and MAX date for 'end_datetime'
SELECT MIN(end_datetime) as min_date,MAX(end_datetime) as max_date
FROM bronze.encounters

--Checing compliance between tables 'bronze.encounters=patient' and 'bronze.patients = id' 
-- Expectation: No Results
SELECT  *
FROM bronze.encounters
WHERE patient NOT IN (SELECT id
			FROM bronze.patients) 

--Checking 'patient' column for NULL values
-- Expectation: No Results
SELECT  *
FROM bronze.encounters
WHERE patient IS  NULL


--Checing compliance between tables 'bronze.encounters' and 'bronze.patients'
SELECT  *
FROM bronze.encounters
WHERE payer NOT  IN (SELECT id
			FROM bronze.payers) 

--Checking 'payer' column for NULL values
-- Expectation: No Results
SELECT  *
FROM bronze.encounters
WHERE payer IS  NULL

-- Data Standardization & Consistency
SELECT DISTINCT encounter_class
FROM bronze.encounters

SELECT DISTINCT code
FROM bronze.encounters

SELECT DISTINCT type_encounter
FROM bronze.encounters

--Checking data range 
SELECT MIN(base_encounter_cost) as min_base_encounter_cost,
		MAX(base_encounter_cost) as max_base_encounter_cost
		FROM bronze.encounters

SELECT MIN(total_claim_cost) as min_total_claim_cost,
		MAX(total_claim_cost) as max_total_claim_cost
FROM bronze.encounters

SELECT MIN(payer_coverage) as min_payer_coverage,
		MAX(payer_coverage) as max_payer_coverage
FROM bronze.encounters


----------------------------------
--Checking 'bronze.patients' table
----------------------------------

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT id, COUNT(*)
FROM bronze.patients
GROUP BY id
HAVING COUNT(*) >1

--Checking date range 
SELECT MIN(birth_date) as min_birth_date
		,MAX(birth_date) as max_birth_date
		,MIN(death_date)as min_death_date
		,MAX(death_date) as max_birth_date
FROM bronze.patients

--Cheking  for duplicates
SELECT DISTINCT prefix
FROM bronze.patients

--Checking string column for appropiate format
-- Expectation: No Results
SELECT DISTINCT first_name
FROM bronze.patients
WHERE first_name != TRIM(first_name)

SELECT DISTINCT last_name
FROM bronze.patients
WHERE last_name != TRIM(last_name)

SELECT DISTINCT suffix
FROM bronze.patients

--Checking for NULL values
SELECT *
FROM bronze.patients
WHERE zip IS NULL

SELECT *
FROM bronze.patients
WHERE lat IS NULL OR lon IS NULL

----------------------------------
--Checking 'bronze.procedures_table' table
----------------------------------
--Checking early and latest date in 'start_datetime','stop_datetime' columns
SELECT 'min_start_date', MIN(start_datetime) FROM bronze.procedures_table
UNION ALL
SELECT 'max_start_date', MAX(start_datetime) FROM bronze.procedures_table
UNION ALL
SELECT 'min_start_date', MIN(stop_datetime) FROM bronze.procedures_table
UNION ALL
SELECT 'min_start_date', MAX(stop_datetime) FROM bronze.procedures_table

--Checking correspondence between foreing  keys 'encounter','patient'
--Expectation: No Results
SELECT *
FROM bronze.procedures_table
WHERE encounter NOT IN (SELECT id
						FROM bronze.encounters) 

SELECT *
FROM bronze.procedures_table
WHERE patient NOT IN (SELECT id
						FROM bronze.patients) 

--Checking number unique values in 'code'column
SELECT COUNT(DISTINCT code)
FROM bronze.procedures_table

--Cheking data quality (extra spase in the start or end questions)
-- Expectation: No Results
SELECT DISTINCT procedure_description
FROM bronze.procedures_table
WHERE procedure_description != TRIM(procedure_description)

--Checking values range 'base_cost' column
--Expectation:'base_cost'>=0
SELECT MIN(base_cost) as min_cost
		,MAX(base_cost) as max_cost
FROM bronze.procedures_table




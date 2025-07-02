/*
===============================================================================
Data Quality Checks silver layer
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
--Checking 'silver.encounters' table
----------------------------------

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT  id,COUNT(*)
FROM silver.encounters
GROUP BY id
HAVING COUNT(*)>1 OR id IS NULL


--Checking MIN and MAX date for 'start_datetime'
SELECT MIN(start_datetime) as min_date,MAX(start_datetime) as max_date
FROM silver.encounters

--Checking MIN and MAX date for 'end_datetime'
SELECT MIN(end_datetime) as min_date,MAX(end_datetime) as max_date
FROM silver.encounters

--Checing compliance between tables 'silver.encounters=patient' and 'silver.patients = id' 
-- Expectation: No Results
SELECT  *
FROM silver.encounters
WHERE patient NOT IN (SELECT id
			FROM silver.patients) 

--Checking 'patient' column for NULL values
-- Expectation: No Results
SELECT  *
FROM silver.encounters
WHERE patient IS  NULL


--Checing compliance between tables 'silver.encounters' and 'silver.patients'
SELECT  *
FROM silver.encounters
WHERE payer NOT  IN (SELECT id
			FROM silver.payers) 

--Checking 'payer' column for NULL values
-- Expectation: No Results
SELECT  *
FROM silver.encounters
WHERE payer IS  NULL

-- Data Standardization & Consistency
SELECT DISTINCT encounter_class
FROM silver.encounters

SELECT DISTINCT code
FROM silver.encounters

SELECT DISTINCT type_encounter
FROM silver.encounters

--Checking data range 
SELECT MIN(base_encounter_cost) as min_base_encounter_cost,
		MAX(base_encounter_cost) as max_base_encounter_cost
		FROM silver.encounters

SELECT MIN(total_claim_cost) as min_total_claim_cost,
		MAX(total_claim_cost) as max_total_claim_cost
FROM silver.encounters

SELECT MIN(payer_coverage) as min_payer_coverage,
		MAX(payer_coverage) as max_payer_coverage
FROM silver.encounters


----------------------------------
--Checking 'silver.patients' table
----------------------------------

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT id, COUNT(*)
FROM silver.patients
GROUP BY id
HAVING COUNT(*) >1

--Checking date range 
SELECT MIN(birth_date) as min_birth_date
		,MAX(birth_date) as max_birth_date
		,MIN(death_date)as min_death_date
		,MAX(death_date) as max_birth_date
FROM silver.patients

--Cheking  for duplicates
SELECT DISTINCT prefix
FROM silver.patients

--Checking string column for appropiate format
-- Expectation: No Results
SELECT DISTINCT first_name
FROM silver.patients
WHERE first_name != TRIM(first_name)

SELECT DISTINCT last_name
FROM silver.patients
WHERE last_name != TRIM(last_name)



--Checking for NULL values
SELECT *
FROM silver.patients
WHERE zip IS NULL

SELECT *
FROM silver.patients
WHERE lat IS NULL OR lon IS NULL

----------------------------------
--Checking 'silver.procedures_table' table
----------------------------------
--Checking early and latest date in 'start_datetime','stop_datetime' columns
SELECT 'min_start_date', MIN(start_datetime) FROM silver.procedures_table
UNION ALL
SELECT 'max_start_date', MAX(start_datetime) FROM silver.procedures_table
UNION ALL
SELECT 'min_start_date', MIN(stop_datetime) FROM silver.procedures_table
UNION ALL
SELECT 'min_start_date', MAX(stop_datetime) FROM silver.procedures_table

--Checking correspondence between foreing  keys 'encounter','patient'
--Expectation: No Results
SELECT *
FROM silver.procedures_table
WHERE encounter NOT IN (SELECT id
						FROM silver.encounters) 

SELECT *
FROM silver.procedures_table
WHERE patient NOT IN (SELECT id
						FROM silver.patients) 

--Checking number unique values in 'code'column
SELECT COUNT(DISTINCT code)
FROM silver.procedures_table

--Cheking data quality (extra spase in the start or end questions)
-- Expectation: No Results
SELECT DISTINCT procedure_description
FROM silver.procedures_table
WHERE procedure_description != TRIM(procedure_description)

--Checking values range 'base_cost' column
--Expectation:'base_cost'>=0
SELECT MIN(base_cost) as min_cost
		,MAX(base_cost) as max_cost
FROM silver.procedures_table




/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze → Silver)
===============================================================================
Description:
	 Loads data into the 'silver' schema from 'bronze' layer by:
		-Truncate targer table;
		-Insert into table cleaning data from bronze layer correspond table;
Parameters:
	None;

Usage:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time=GETDATE()
		PRINT  '================================================';
		PRINT 'Loading Silver Layer';
		PRINT  '================================================';

		PRINT  '================================================';
		PRINT 'Loading silver.encounters table';
		PRINT  '================================================';
		
		SET @start_time=GETDATE()
		PRINT '>>Truncate table silver.encounters'
		TRUNCATE TABLE silver.encounters;
		PRINT '>>Insert data into silver.encounters from bronze.encounters'
		INSERT INTO silver.encounters(
				[id]
			  ,[start_datetime]
			  ,[end_datetime]
			  ,[patient]
			  ,[organization]
			  ,[payer]
			  ,[encounter_class]
			  ,[code]
			  ,[type_encounter]
			  ,[base_encounter_cost]
			  ,[total_claim_cost]
			  ,[payer_coverage]
			  ,[reason_code]
			  ,[reason_description])
		SELECT 
			id,
			start_datetime,
			end_datetime,
			patient,
			organization,
			payer,
			encounter_class,
			code,
			LOWER(type_encounter),
			base_encounter_cost,
			total_claim_cost,
			payer_coverage,
			CASE WHEN reason_code IS NOT NULL THEN 	reason_code
					ELSE 'n/a'
			END AS reason_code,
			CASE WHEN reason_description IS NOT NULL THEN reason_description
				ELSE 'n/a'
			END AS reason_code
		FROM bronze.encounters;
		SET @end_time=GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time,@end_time) AS nvarchar) + ' seconds'; 
		PRINT '>>  -------------';


		PRINT  '================================================';
		PRINT 'Loading silver.patients table';
		PRINT  '================================================';
		SET @start_time=GETDATE()

		PRINT '>>Truncate table silver.patients'
		TRUNCATE TABLE silver.patients;

		PRINT '>>Insert data into silver.patients from bronze.patients'
		INSERT INTO silver.patients(
				[id]
			  ,[birth_date]
			  ,[death_date]
			  ,[prefix]
			  ,[first_name]
			  ,[last_name]
			  ,[maiden]
			  ,[marital]
			  ,[race]
			  ,[ethnicity]
			  ,[gender]
			  ,[birth_place]
			  ,[address]
			  ,[city]
			  ,[state]
			  ,[county]
			  ,[zip]
			  ,[lat]
			  ,[lon]
		) SELECT 
				id,
				birth_date,
				death_date,
				prefix,
				CASE WHEN first_name LIKE '%[^a-zA-Z0-9]%'  OR first_name LIKE '%Ü%' THEN 'n/a'
						WHEN first_name LIKE '%[A-Z][0-9]' THEN SUBSTRING(first_name,1,LEN(first_name)-1)
						WHEN first_name LIKE '%[A-Z][0-9][0-9]' THEN SUBSTRING(first_name,1,LEN(first_name)-2)
						WHEN first_name LIKE '%[A-Z][0-9][0-9][0-9]' THEN SUBSTRING(first_name,1,LEN(first_name)-3)
				END as first_name,
				CASE WHEN last_name LIKE '%[^a-zA-Z0-9]%'  OR last_name LIKE '%Ü%' THEN 'n/a'
						WHEN last_name LIKE '%[A-Z][0-9]' THEN SUBSTRING(last_name,1,LEN(last_name)-1)
						WHEN last_name LIKE '%[A-Z][0-9][0-9]' THEN SUBSTRING(last_name,1,LEN(last_name)-2)
						WHEN last_name LIKE '%[A-Z][0-9][0-9][0-9]' THEN SUBSTRING(last_name,1,LEN(last_name)-3)
				END as last_name,
				CASE WHEN maiden LIKE '%[^a-zA-Z0-9]%' or maiden LIKE '%Ü%' THEN 'n/a'
						WHEN maiden LIKE '%[A-Z][0-9]' THEN SUBSTRING(maiden,1,LEN(maiden)-1)
						WHEN maiden LIKE '%[A-Z][0-9][0-9]' THEN SUBSTRING(maiden,1,LEN(maiden)-2)
						WHEN maiden LIKE '%[A-Z][0-9][0-9][0-9]' THEN SUBSTRING(maiden,1,LEN(maiden)-3)
						ELSE 'n/a'
				END as maiden,
				CASE WHEN marital = 'M' THEN 'Married'
					WHEN marital='S' THEN 'Single'
					ELSE 'n/a'
				END AS marital,
				TRIM(race) as race,
				TRIM(ethnicity) as ethnicity,
				CASE WHEN gender ='M' THEN 'Male'
					WHEN gender ='F' THEN 'Female'
					ElSE 'n/a'
				END AS gender,
				birth_place,
				address,
				city,
				state ,
				TRIM(REPLACE(country, ' Country','')) as county,
				CASE WHEN zip  IS NOT NULL THEN CAST(zip AS NVARCHAR)
					ELSE 'n/a'
				END AS zip,
				lat,
				lon
			FROM bronze.patients;

		SET @end_time =GETDATE()
		PRINT '>>  -------------';
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time,@end_time) AS nvarchar) + ' seconds'; 
		PRINT '>>  -------------';
		
		PRINT  '================================================';
		PRINT 'Loading silver.payers table';
		PRINT  '================================================';
		SET @start_time=GETDATE()

		PRINT '>>Truncate table silver.payers'
		TRUNCATE TABLE silver.payers;

		PRINT '>>Insert data into silver.payers from bronze.payers'
		INSERT INTO silver.payers (
				[id]
			  ,[name]
			  ,[address]
			  ,[city]
			  ,[state_headquartered]
			  ,[zip]
			  ,[phone]
		) SELECT id,
				TRIM(name) AS name,
				TRIM(address) AS address,
				TRIM(city) AS city,
				TRIM(state_headquartered) AS state_headquartered,
				zip,
				REPLACE(phone,'-',' ') AS phone
			FROM bronze.payers;

		SET @end_time =GETDATE()
		PRINT '>>  -------------';
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time,@end_time) AS nvarchar) + ' seconds'; 
		PRINT '>>  -------------';

		PRINT  '================================================';
		PRINT 'Loading silver.procedures_table table';
		PRINT  '================================================';
		SET @start_time=GETDATE()

		PRINT '>>Truncate table silver.procedures_table'
		TRUNCATE TABLE silver.procedures_table;
	
		PRINT '>>Insert data into silver.procedures_table from bronze.procedures_table'
		INSERT INTO silver.procedures_table (
				[start_datetime]
			  ,[stop_datetime]
			  ,[patient]
			  ,[encounter]
			  ,[code]
			  ,[procedure_description]
			  ,[base_cost]
			  ,[reason_code]
			  ,[reason_description]
		) SELECT start_datetime,
				stop_datetime,
				patient,
				encounter,
				code,
				LOWER(procedure_description) AS procedure_description,
				base_cost,
				reason_code,
				reason_description
			FROM bronze.procedures_table;

		SET @end_time =GETDATE()
		PRINT '>>  -------------';
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time,@end_time) AS nvarchar) + ' seconds'; 
		PRINT '>>  -------------';

		SET @batch_end_time=GETDATE()
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==========================================';
		
	END TRY
	BEGIN CATCH
		PRINT '================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error message: '+ ERROR_MESSAGE();
		PRINT 'Error number: '+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================';
	END CATCH
END


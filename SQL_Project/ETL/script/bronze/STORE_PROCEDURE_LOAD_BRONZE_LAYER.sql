/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source → Bronze)
===============================================================================
Description:
    Loads data into the 'bronze' schema from CSV files by:
    - Truncating target tables
    - Using BULK INSERT to import data

Parameters:
    None

Usage:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time=GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';
		
		PRINT '================================================';
		PRINT 'Loading encounters table';
		PRINT '================================================';
		
		SET @start_time=GETDATE();
		PRINT '>> Truncating Table:bronze.encounters';
		TRUNCATE TABLE bronze.encounters;
		
		PRINT '>> Bulk insert data:bronze.encounters';
		BULK INSERT bronze.encounters
		FROM 'C:\Users\HP\Downloads\SQL Proqect\Hospital+Patient+Records\encounters.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time=GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) +' seconds';
		PRINT '>> -------------';

		PRINT '================================================';
		PRINT 'Loading patients table';
		PRINT '================================================';

		SET @start_time=GETDATE();
		PRINT '>> Truncating Table:bronze.patients';
		TRUNCATE TABLE bronze.patients;

		PRINT '>> Bulk insert data:bronze.patients';
		BULK INSERT bronze.patients
		FROM 'C:\Users\HP\Downloads\SQL Proqect\Hospital+Patient+Records\patients.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

		SET @end_time=GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time, @end_time)AS NVARCHAR) +' seconds';
		PRINT '>> -------------';

		PRINT '================================================';
		PRINT 'Loading payers table';
		PRINT '================================================';
		SET @start_time=GETDATE();
		PRINT '>> Truncating Table:bronze.payers';
		TRUNCATE TABLE bronze.payers;
		

		PRINT '>>Loading payers table';

		BULK INSERT bronze.payers
		FROM 'C:\Users\HP\Downloads\SQL Proqect\Hospital+Patient+Records\payers.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
	
		SET @end_time=GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time, @end_time)AS NVARCHAR) +' seconds';
		PRINT '>> -------------';
		
		PRINT '================================================';
		PRINT 'Loading procedures_table table';
		PRINT '================================================';
		SET @start_time=GETDATE();
		PRINT '>> Truncating Table:bronze.procedures_table';
		TRUNCATE TABLE bronze.procedures_table;
		
		BULK INSERT bronze.procedures_table
		FROM 'C:\Users\HP\Downloads\SQL Proqect\Hospital+Patient+Records\procedures.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		
		SET @end_time=GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time)AS NVARCHAR) +' seconds';
		PRINT '>> -------------';

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



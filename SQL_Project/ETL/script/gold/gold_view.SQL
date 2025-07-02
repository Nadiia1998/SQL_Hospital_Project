/*
===============================================================================
DDL Script: Gold Layer View Creation
===============================================================================
Overview:
    This script defines views that make up the Gold layer of the data warehouse. 
    The Gold layer serves as the presentation layer, organizing data into 
    fact and dimension tables following a Star Schema design.

Function:
    Each view integrates and transforms data from the Silver layer, delivering 
    a refined, business-ready dataset suitable for analysis and reporting.

Intended Use:
    - Designed for direct use in dashboards, reports, and advanced analytics.
===============================================================================
*/

--------------------------------------------
--Drop 'gold.dim_payers' view if it's exists;
--------------------------------------------
IF OBJECT_ID('gold.dim_payers','V') IS NOT NULL
	DROP VIEW gold.dim_payers;
GO

--------------------------------------------
--Create view base on silver.payers table;
--------------------------------------------
CREATE VIEW gold.dim_payers 
AS
	SELECT ROW_NUMBER() OVER(ORDER BY payer_id) as payer_key, --Surrogate key 
			*
	FROM (
		SELECT
			id as payer_id,
			name as payer_name,
			address as address,
			city,
			state_headquartered as headquartered_state,
			zip,
			phone
		FROM silver.payers
			UNION ALL
		SELECT DISTINCT payer, 'Unknown','Unknown','Unknown','Unknown',NULL, NULL -- Add payer id, which exists in encounters table 
		FROM silver.encounters
		WHERE payer NOT IN (SELECT id FROM silver.payers)) as t
GO

----------------------------------------------
--Drop 'gold.dim_patients' view if it's exists;
--------------------------------------------
IF OBJECT_ID('gold.dim_patients','V') IS NOT NULL
	DROP VIEW gold.dim_patients;
GO

--------------------------------------------
--Create view base on silver.patients table;
--------------------------------------------
CREATE VIEW gold.dim_patients
AS
	SELECT 
			ROW_NUMBER() OVER (ORDER by birth_date) as patient_key, -- Surrogate key
			id as patient_id,
			first_name,
			last_name,
			birth_date,
			CASE WHEN death_date IS  NULL THEN DATEDIFF(year,birth_date,GETDATE()) 
				ELSE DATEDIFF(year, birth_date,death_date) 
			END as age,
			death_date,
			gender,
			marital,
			race,
			address,
			city,
			county,
			zip
	FROM silver.patients;
GO


--------------------------------------------
--Drop 'gold.dim_procedure' view if it's exists;
--------------------------------------------
IF OBJECT_ID('gold.dim_procedures','V') IS NOT NULL
	DROP VIEW gold.dim_procedures;
GO

--------------------------------------------
--Create view base on silver.procedure_table;
--------------------------------------------
CREATE VIEW gold.dim_procedures
AS
	SELECT 
		ROW_NUMBER() OVER (ORDER BY patient) as procedure_key, --Surrogate key
		patient as patient_id,
		encounter as encounter_id,
		start_datetime as start_procedure,
		stop_datetime as end_procedure,
		code,
		CASE WHEN procedure_description LIKE '% (%' THEN SUBSTRING(procedure_description,1,CHARINDEX('(',procedure_description) -1)
			ELSE procedure_description END AS procedure_description,
		base_cost,
		CASE WHEN reason_code IS NOT NULL THEN reason_code
			ELSE 'n/a'
		END AS reason_code,
		CASE WHEN reason_description IS NOT NULL THEN reason_description
			ELSE 'n/a'
		END AS reason_description
	FROM silver.procedures_table
	WHERE encounter NOT IN (SELECT  id  --execute from gold layer procedure where total_claim_cost for encounters =0 (46 records)
								FROM  silver.encounters
								WHERE  total_claim_cost =0);
GO


/*
		NOTE

	A join is performed between gold.fact_encounters and gold.dim_procedures.
	This is a one-to-many relationship, as multiple procedures can be associated with a single encounter.

	The expected calculation for the total claim cost is:
		-base_procedure_cost + base_encounter_cost = total_claim_cost.

	However, during data validation, discrepancies were identified:
		-base_procedure_cost + base_encounter_cost ≠ total_claim_cost.

	As a result, the following logic has been implemented:

	 Add two addition columns:
		- discount: base_procedure_cost+base_encounter_cost <= total_claim_cost 
					-> total_claim_cost-(base_procedure_cost+base_encounter_cost)
		- addition pay:base_procedure_cost+base_encounter_cost >= total_claim_cost)
					-> (base_procedure_cost + base_encounter_cost) - total_claim_cost


	!!! I IMPLEMENTED THIS STEP IN CASE THERE ARE NO ADDITION INFORMATION EXPLAINING WHY 
			base_procedure_cost + base_encounter_cost ≠ total_claim_cost.
		IN  A REAL PROJECT I WOULD  NEED CLARIFICATION ON HOW THIS SHOUL BE CALCULATED CORRECTLY.
*/

--------------------------------------------
--Drop 'gold.fact_encounters' view if it's exists;
--------------------------------------------
IF OBJECT_ID('gold.fact_encounters','V') IS NOT NULL
	DROP VIEW gold.fact_encounters;
GO

--------------------------------------------
--Create view base on silver.encounters table;
-------------------------------------------- 

CREATE VIEW gold.fact_encounters  
AS
WITH cte_procedure AS (
	SELECT encounter,
		SUM(base_cost) as base_cost
FROM silver.procedures_table
GROUP BY encounter)
, cte_main AS(
	SELECT 
		e.id,
		e.patient,
		e.payer,
		e.start_datetime,
		CASE WHEN DATEDIFF(day,e.start_datetime,e.end_datetime) >27 THEN DATEADD(hour,7,e.start_datetime)
			ELSE e.end_datetime
		END AS  end_datetime,
		e.encounter_class,
		e.code,
		e.type_encounter,
		ROUND(e.base_encounter_cost,0) as base_encounter_cost,
		ROUND(p.base_cost,0) as base_procedure_cost,
		ROUND(e.total_claim_cost,0) as total_claim_cost,
		ROUND(e.payer_coverage,0) as payer_coverage,
		CASE WHEN e.reason_code IS NOT NULL THEN  e.reason_code
			ELSE 'n/a'
		END AS reason_code, --Replace NULL values 'n/a'
		CASE WHEN e.reason_description IS NOT NULL THEN e.reason_description
			ELSE 'n/a'
		END AS reason_description --Replace NULL values 'n/a'
	FROM silver.encounters AS e
	LEFT JOIN cte_procedure AS p
	ON e.id=p.encounter)


SELECT  ROW_NUMBER() OVER (ORDER BY start_datetime) as encounter_key, --Create surrogate key, 
		id as encounter_id,
		patient as patient_id,
		payer as payer_id,
		start_datetime as start_encounter,
		end_datetime as end_encounter,
		encounter_class,
		code,
		CASE WHEN type_encounter LIKE '% (%' THEN SUBSTRING(type_encounter,1,CHARINDEX('(',type_encounter) -1)
			ELSE type_encounter END AS type_encounter,
		base_encounter_cost,
		CASE	
			WHEN   (base_procedure_cost+base_encounter_cost <= total_claim_cost)
				THEN (total_claim_cost-(base_procedure_cost+base_encounter_cost))
			ELSE 0
		END AS addition_pay,
		CASE WHEN (base_procedure_cost+base_encounter_cost >= total_claim_cost)
				THEN ((base_procedure_cost + base_encounter_cost) - total_claim_cost)
			ELSE 0
		end as discount,
		total_claim_cost,
		payer_coverage,
		reason_code,
		reason_description
FROM cte_main
WHERE id NOT IN (SELECT  id
	FROM  silver.encounters
	WHERE  total_claim_cost =0); -- exclude from gold layer data where total_claim_cost =0 (89 records);
GO






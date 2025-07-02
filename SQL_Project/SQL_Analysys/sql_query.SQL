USE HospitalWatehouseAnalysys

-------------------------------------------------------
/* 
	This SQL query calculates the average values of the following metrics:
		-total number of encounters
		- base encounter cost,
		- total cost,
		- discount,
		- additional cost,
		- payer cover

		Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------
SELECT 'number of encountesr' as metric, COUNT(*) as value FROM gold.fact_encounters
UNION ALL
SELECT 'base encounter cost per visit' , ROUND(AVG(base_encounter_cost),2)  FROM gold.fact_encounters
UNION ALL
SELECT 'average discount per visit',ROUND(AVG(discount),2)  FROM gold.fact_encounters
UNION ALL
SELECT 'average addition cost per visit',ROUND(AVG(addition_pay),2)  FROM gold.fact_encounters
UNION ALL
SELECT 'average total cost per visit', ROUND(AVG(total_claim_cost),2)  FROM gold.fact_encounters
UNION ALL
SELECT 'average payer cover per visit',ROUND(AVG(payer_coverage),2)  FROM gold.fact_encounters;


-------------------------------------------------------
/*
		This SQL query returns:

			- the year,
			- the number of unique patients per year,
			- the year-over-year percentage change in the number of patients.

		Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------
WITH cte_patient_count as(
	SELECT YEAR(start_encounter) as years,
			COUNT(distinct patient_id) as number_patients
	from gold.fact_encounters
	group by YEAR(start_encounter)
),
cte_calculate as(
	SELECT *,LAG(number_patients) OVER (ORDER BY years) as previous_year_patient_number
	FROM cte_patient_count)

SELECT 
	years,
	number_patients,
	CONCAT(
		FORMAT(
			COALESCE((number_patients  - previous_year_patient_number)*100.0/ 
				NULLIF(previous_year_patient_number,0) --avoiding divided by zero;
			,0) -- replace NULL -> 0 ;
		,'N2') -- FORMAT output to 2 decimal places;
	,'%') as change_patient_number_YOY
from cte_calculate;

----------------------------------------------
/*

		This SQL query returns:
			- the year,
			- the number of encounters per year,
			- the year-over-year percentage change in the number of encounters.
*/
----------------------------------------------
WITH cte_patient_count as(
	SELECT YEAR(start_encounter) as years,
			COUNT(*) as number_encounters
			from gold.fact_encounters
	group by YEAR(start_encounter)
),
cte_calculate as(
	SELECT *,
	LAG(number_encounters) OVER (ORDER BY years) as previous_year_encounters_number
	FROM cte_patient_count)

SELECT 
	years,
	number_encounters,
	CONCAT(
		FORMAT(
			COALESCE((number_encounters  - previous_year_encounters_number)*100.0/ --replace NULL -> 0;
							NULLIF(previous_year_encounters_number,0)
			,0)
		,'N2') -- change format: rounds too 2 decimal number;
	, '%') as change_encounters_over_year -- add '%'
from cte_calculate; 

-------------------------------------------------------
 /* 
	This query return:
		- the payer name;
		- the average percentage of medical expenses covered by the insurance company;
		- the average total cost for encounters;
		- the average payer coverage;
		- the number of patient who use insurance services;
	
	Period:
		-2011-01-02 -> 2022-02-05
*/

------------------------------------------------------- 
SELECT COALESCE(p.payer_name,'n/a') AS payer_name,
	CONCAT(
		FORMAT(
			AVG(e.payer_coverage/NULLIF(e.total_claim_cost,0)*100),
		'N2'),
	'%') AS expenses_covered_payer
	,ROUND(AVG(e.total_claim_cost),2) AS avg_total_cost,
	ROUND(AVG(e.payer_coverage),2) as avg_payer_coverage,
	COUNT(distinct e.patient_id) as number_of_patient
FROM gold.fact_encounters AS e
left join gold.dim_payers AS p
ON e.payer_id=p.payer_id
GROUP BY p.payer_name
ORDER BY 2 DESC,1 ASC;

-------------------------------------------------------
/* 
	Checking is there are any seasonality;

	This query return:
		-month name;
		-number of encounters per month;
		-the percentage of encounters per month (calculated as: number of encounters in the month / total number of encounters).;
	
	Period:
		-2011-01-02 -> 2022-12-31;
		-exclude 2022, because only half of the year is available;
*/
-------------------------------------------------------
SELECT month_name,
		number_of_encounters,
		CONCAT(FORMAT(number_of_encounters*1.0/(SUM(number_of_encounters) over())*100,'N2'),'%') AS persentage_of_encounters_number
FROM(
	SELECT MONTH(start_encounter) as month_number
			,DATENAME(month,start_encounter) as month_name
			,COUNT(*) as number_of_encounters
	FROM (SELECT *
			FROM gold.fact_encounters
			WHERE YEAR(start_encounter) <2022
		) AS filter_year
	GROUP BY MONTH(start_encounter),DATENAME(month,start_encounter)
	) as t
ORDER BY month_number;

-------------------------------------------------------
/* 
	This query return top 5 procedures YOY : 
		-the rank of the procedure by base cost;
		-the year of procedure;
		-the procedure code;
		-the description of procedure;
		-the base cost;

	Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------

WITH procedure_cte as (
	SELECT
			YEAR(start_procedure) as year_of_procedure,
			code,
			reason_description,
			avg(base_cost) as base_cost
	FROM gold.dim_procedures
	GROUP BY YEAR(start_procedure), code, reason_description)
,rank_cte AS (
	SELECT *,
			DENSE_RANK() OVER (PARTITION BY year_of_procedure ORDER BY base_cost desc) as rank_procedure_cost
	FROM procedure_cte)

SELECT rank_procedure_cost as rank_top,
		year_of_procedure,
		code,
		reason_description,
		base_cost
FROM rank_cte
WHERE rank_procedure_cost <=5;


-------------------------------------------------------
/* 
	This query return the cheapest 5 procedures by bace cost YOY : 
		- the procedure's rank based on base cost.
		- the year of procedure;
		- the procedure code;
		- the base cost;

	Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------

WITH procedure_cte as (
	SELECT
			YEAR(start_procedure) as year_of_procedure,
			code,
			reason_description,
			avg(base_cost) as base_cost
	FROM gold.dim_procedures
	GROUP BY YEAR(start_procedure), code, reason_description)
,rank_cte AS (
	SELECT *,
			ROW_NUMBER() OVER (PARTITION BY year_of_procedure ORDER BY base_cost) as rank_procedure_cost
	FROM procedure_cte)

SELECT rank_procedure_cost as rank_top,
		year_of_procedure,
		code,
		base_cost
FROM rank_cte
WHERE rank_procedure_cost <=5;


-------------------------------------------------------
/* 
	This SQL query returns the number of encounters and total cost for males and females, along with their respective proportions, including:
		- gender,
		- number of encounters per gender,
		- proportion of encounters per gender,
		- average total cost per gender,
		- proportion of total cost per gender.

	Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------

SELECT gender,
		number_parient,
		CONCAT(
			FORMAT(number_parient*1.0/SUM(number_parient) OVER (),'N2'),
		'%') as persentege_of_gender,
		average_cost_per_gender,
		CONCAT(
			FORMAT(average_cost_per_gender*1.0/SUM(average_cost_per_gender) OVER(),'N2'),
		'%') as persentege_of_total_cost_per_gender
FROM 
	(SELECT p.gender, 
			COUNT(*) as number_parient,
			ROUND(AVG(e.total_claim_cost),2) as average_cost_per_gender
	FROM gold.fact_encounters as e
	LEFT JOIN gold.dim_patients as  p
	ON e.patient_id=p.patient_id
	GROUP BY gender) as t
ORDER BY number_parient desc;

-------------------------------------------------------
/* 
	This SQL query returns:
		- the encounter class (ambulatory, outpatient, emergency, urgentcare, wellness, inpatient),
		- the number of unique patients by encounter class,
		- the percentage of patients by encounter class.
	Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------

SELECT encounter_class,
	number_of_patients,
	CONCAT(
			FORMAT(number_of_patients*1.0/SUM(number_of_patients) OVER()*100 , 'N2'),
	'%') as persentage_of_patiens
	FROM (
	SELECT encounter_class,
		COUNT(distinct patient_id) as number_of_patients
	FROM gold.fact_encounters
	GROUP BY encounter_class
	) as t
ORDER BY number_of_patients DESC;

-------------------------------------------------------
/* 
	This SQL query returns:
		- the encounter class (ambulatory, outpatient, emergency, urgentcare, wellness, inpatient),
		- the average total cost per encounter,
	Period:
		-2011-01-02 -> 2022-02-05
*/
-------------------------------------------------------


SELECT encounter_class,
	ROUND(AVG(total_claim_cost),2) as avg_cost_per_encounter_class
FROM gold.fact_encounters
GROUP BY encounter_class
ORDER BY 2 DESC
	

-------------------------------------------------------
/* 
	This SQL query returns:
		- the age category (under 30, 30-40, 40-50, 50-60, 60-70, over 80)
		- the average total cost per age
		- the persantege of payer coverage for year categories
*/
-------------------------------------------------------
SELECT  t.age_categories,
		COUNT(*) as numbers_of_encounters,
		ROUND(AVG(e.total_claim_cost),2) as avg_total_cost,
		CONCAT(
			FORMAT(AVG(e.payer_coverage*1.0 /e.total_claim_cost) * 100, 'N2'),
		'%') as persantege_payer_cover
FROM gold.fact_encounters as e
LEFT JOIN (
	SELECT
	patient_id,
	age,
	CASE 
		WHEN age > =90 then 'over 90' 
		WHEN age > =80  and age <90 then 'over 80' 
		WHEN age >= 70 and age <80 then '70-79'
		WHEN age >= 60 and age <70 then '60-69'
		WHEN age >= 50 and age <60 then '50-59'
		WHEN age >= 40 and age <50 then '40-49'
		WHEN age >= 30 and age <40 then '30-39'
		ELSE 'under 30'
	END AS age_categories
FROM gold.dim_patients ) as t
ON e.patient_id=t.patient_id
GROUP BY t.age_categories
ORDER BY ROUND(AVG(e.total_claim_cost),2) DESC;



/*
		This query returns a comparison of the number  of encounters without procedures/with procedure:
			- the number on encounters;
			- persentage of encounters without/with procedure compared to all records;
			- average total cost per encounters;
			- persentage of payer coverage;
*/

SELECT	'encounters_without_procedure' as metrics,
		COUNT(*) as number_of_encounters,
		CONCAT(
			FORMAT(COUNT(*) * 1.0 / (SELECt count(*)
									FROM gold.fact_encounters),'N2')
		,'%') as per_encounters,
		ROUND(AVG(total_claim_cost),2) as avg_cost_per_procedure,
		CONCAT(
			FORMAT(AVG(payer_coverage *1.0 /total_claim_cost),'N2')
		,'%') as pers_payers_coverage
FROM gold.fact_encounters
WHERE encounter_id NOT IN (SELECT  encounter_id
						FROM gold.dim_procedures )
UNION ALL
SELECT 'encounters_with_procedure',
		COUNT(*),
		CONCAT(
			FORMAT(COUNT(*) * 1.0 / (SELECt count(*)
									FROM gold.fact_encounters),'N2')
		,'%') ,
		ROUND(AVG(total_claim_cost),2),
		CONCAT(
			FORMAT(AVG(payer_coverage *1.0 /total_claim_cost),'N2')
		,'%') 
FROM gold.fact_encounters
WHERE encounter_id  IN (SELECT  encounter_id
						FROM gold.dim_procedures);




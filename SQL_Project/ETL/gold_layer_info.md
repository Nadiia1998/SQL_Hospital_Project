## Gold Layers Documentation

#### This document provides a detailed description of the column structure in the SQL database. Each column listed below includes its name,constraints (if any), and a brief explanation of its purpose within the dataset.  Use this as a reference for understanding the schema, validating data integrity, and building queries effectively.
---

#### 📋 fact_procedure
##### This table contains information about procedures performed on patients, including surgeries and other medical interventions. Each row represents a single procedure and includes metadata such as cost, timing, and reason for the procedure.

| Column Name             | Description                                                                                                          |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `procedure_key`         | **Surrogate Key.** Auto-incrementing integer.                                                                        |
| `patient_id`            | **Foreign Key.** Identifier linking the procedure to the corresponding patient.                                      |
| `encounter_id`          | **Foreign Key.** Identifier linking the procedure to the clinical encounter in which it was performed.               |
| `code`                  | Procedure code from **SNOMED-CT**, identifying the specific medical procedure.                                       |
| `procedure_description` | Textual description of the procedure.                                                                                |
| `base_cost`             | The line item cost of the procedure (excluding other services).                                                      |
| `reason_code`           | **SNOMED-CT** diagnosis code specifying the reason this procedure was performed.                                     |
| `reason_description`    | Description of the reason for the procedure, based on the diagnosis code.                                            |
| `start_procedure`       | The date and time the procedure was started, in **ISO 8601 UTC format** (`yyyy-MM-dd'T'HH:mm'Z'`).                   |
| `end_procedure`         | The date and time the procedure was completed (if applicable), in **ISO 8601 UTC format** (`yyyy-MM-dd'T'HH:mm'Z'`). |
---

#### 📋 dim_encounters
##### This table records details of clinical encounters for patients, including the type and classification of each encounter, timing, costs, payer information, and associated diagnoses. Each encounter is uniquely identified and linked to a payer and diagnostic codes standardized by SNOMED-CT.

| **Column Name**         | **Description**                                                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `encounter_key`         | **Surrogate key**  Auto-incrementing integer.                                                                                           |
| `encounter_id`          | **Primary Key** Unique identifier of the encounte.                                                                                      |
| `payer_id`              | **Foreign Key** Identifier for the payer (e.g., insurance provider or other coverage entity).                                          |
| `encounter_class`       | The class of the encounter, such as `ambulatory`, `emergency`, `inpatient`,`outpatient`, `wellness`, or `urgentcare`.                  |
| `code`                  | Encounter code from **SNOMED-CT**, indicating the standardized classification of the encounter.                                        |
| `type_encounter`        | Textual description of the type of encounter (e.g., routine check-up, follow-up visit).                                                |
| `base_encounter_cost`   | The **base cost of the encounter**, *not including* any line item costs for medications, immunizations, procedures, or other services. |
| `total_claim_cost`      | The **total cost of the encounter**, including all line item costs.                                                                    |
| `payer_coverage`        | The **amount of cost covered by the payer**, such as an insurance company.                                                             |
| `diagnosis_code`        | **Diagnosis code from SNOMED-CT**, only if this encounter targeted a specific condition.                                               |
| `diagnisis_description` | Description of the diagnosis or reason for the encounter, related to the diagnosis code.                                               |
| `start_encounter`       | The **start date and time** of the encounter (`yyyy-MM-dd'T'HH:mm'Z'`).                                                                |
| `end_encounder`         | The **end date and time** of the encounter (`yyyy-MM-dd'T'HH:mm'Z'`).                                                                  |
---

#### 📋 dim_patients
##### This table contains core demographic, geographic, and status information about each patient. Each row represents a unique patient, identified by a primary key. 
| Column Name   | Description                                                                                                    |
| ------------- | -------------------------------------------------------------------------------------------------------------- |
| `patient_key` | **Surrogate key** Auto-incrementing integer.                                                                   |
| `patient_id`  | **Primary Key** Unique identifier of the patient.                                                              |
| `birth_date`  | The date the patient was born (`YYYY-MM-DD`).                                                                  |
| `age`         | Patient’s age, typically calculated based on `birth_date` and either current date or `death_date` if deceased. |
| `death_date`  | The date the patient died, if applicable (`YYYY-MM-DD`).                                                       |
| `first_name`  | First name of the patient.                                                                                     |
| `last_name`   | Last name of the patient.                                                                                      |
| `gender`      | Gender of the patient:`Male`,`Female`,`n/a`.                                                                   |
| `marital`     | Marital status: `Single`, `Mariadde`,`n/a`                                                                     |
| `race`        | Description of the patient’s primary race: `asian`, `black`,`white`,`hawaiian`, `native`,`other`.              |
| `address`     | Patient's street address (without commas or newlines).                                                         |
| `city`        | City of the patient’s address.                                                                                 |
| `county`      | County of the patient’s address.                                                                               |
| `zip`         | ZIP code of the patient’s address.                                                                             |
---

#### 📋dim_payers
##### This table contains information about payers, such as insurance companies or other coverage providers. Each row represents a unique payer entity with address and contact details.

| Column Name           | Description                                                 |
| --------------------- | ----------------------------------------------------------- |
| `payer_key`           | **Surrogate key.** Auto-incrementing integer.               |
| `payer_id`            | **Primary key.** Unique identifier of the payer.            |
| `payer_name`          | Name of the payer (e.g., insurance company name).           |
| `address`             | Payer's street address (without commas or newlines).        |
| `city`                | City of the payer’s address.                                |
| `headquartered_state` | Abbreviation of the state where the payer is headquartered. |
| `zip`                 | ZIP or postal code of the payer’s address.                  |
| `phone`               | Payer's phone number.                                       |

---

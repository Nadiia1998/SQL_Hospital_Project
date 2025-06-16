## 📦 Bronze Layer - Source Data Description

The Bronze layer stores raw, untransformed data ingested from external sources. Below is an overview of the tables and fields included in the source data schema.

---

### 🏥 `encounters` - Patient Encounter Data

| Field               | Description                                                                 |	
|---------------------|-----------------------------------------------------------------------------|
| id                  | Primary key. Unique identifier of the encounter.                            |
| start_datatime      | Start date/time of the encounter (ISO 8601 UTC format).                     |
| end_datatime        | End date/time of the encounter (ISO 8601 UTC format).                       |
| patient             | Foreign key to the `patients` table.                                        |
| organization        | Foreign key to the `organizations` table.                                   |
| payer               | Foreign key to the `payers` table.                                          |
| encounter_class     | Class of the encounter (e.g., ambulatory, emergency, inpatient).            |
| code                | SNOMED-CT code for the encounter type.                                      |
| type_encounter      | Description of the encounter type.                                          |
| base_encounter_cost | Base cost, excluding medications, procedures, etc.                          |
| total_claim_cost    | Total cost of the encounter, including all items.                           |
| payer_coverage      | Amount covered by the payer.                                                |
| reason_code         | SNOMED-CT diagnosis code, if targeted condition exists.                     |
| reason_description  | Description of the diagnosis code.                                          |

---


### 🧑‍⚕️ `patients` - Patient Demographic Data

| Field            | Description                                                  |
|------------------|--------------------------------------------------------------|
| id               | Primary key. Unique identifier of the patient.               |
| birth_date       | Birth date of the patient (YYYY-MM-DD).                      |
| death_date       | Death date, if applicable (YYYY-MM-DD).                      |
| prefix           | Name prefix (Mr., Mrs., Dr., etc.).                          |
| first_name       | First name.                                                  |
| last_name        | Last/surname.                                                |
| suffix           | Name suffix (PhD, MD, etc.).                                 |
| maiden           | Maiden name.                                                 |
| marital          | Marital status (M = married, S = single).                    |
| race             | Patient's primary race.                                      |
| ethnicity        | Patient's primary ethnicity.                                 |
| gender           | Gender (M = male, F = female).                               |
| birth_place      | Town where the patient was born.                             |
| address          | Street address (no commas or newlines).                      |
| city             | City of residence.                                           |
| state            | State of residence.                                          |
| county           | County of residence.                                         |
| zip              | Zip/postal code.                                             |
| lat              | Latitude of address.                                         |
| lon              | Longitude of address.                                        |

---

### 💳 `payers` - Insurance Provider Data

| Field                | Description                                               |
|----------------------|-----------------------------------------------------------|
| id                   | Primary key. Unique identifier of the payer.              |
| name                 | Name of the payer.                                        |
| address              | Street address (no commas or newlines).                   |
| city                 | City of the payer.                                        |
| state_headquartered  | State where the payer is headquartered.                 |
| zip                  | Zip/postal code.                                          |
| phone                | Payer’s phone number.                                     |

---

### 🏥 `procedures` - Medical Procedure Data

| Field                  | Description                                                             |
|------------------------|-------------------------------------------------------------------------|
| start_datetime         | Date/time when the procedure was performed (ISO 8601 UTC format).       |
| stop_datetime          | Completion date/time, if available.                                     |
| patient                | Foreign key to the `patients` table.                                    |
| encounter              | Foreign key to the associated encounter.                                |
| code                   | SNOMED-CT code for the procedure.                                       |
| procedure_description  | Description of the procedure.                                           |
| base_cost              | Cost of the procedure.                                                  |
| reason_code            | SNOMED-CT diagnosis code related to the procedure.                      |
| reason_description     | Description of the reason for the procedure.                            |

---

> ⚠️ **Note:** This data is loaded into the Bronze layer as-is from source systems and should be treated as raw and unvalidated. Minimal transformations are applied at this stage to maintain full traceability.

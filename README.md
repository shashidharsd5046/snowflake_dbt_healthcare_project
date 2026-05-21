# Snowflake & dbt Healthcare Analytics Pipeline

This repository contains a modern **dbt (Data Build Tool)** analytics engineering project integrated with **Snowflake**. The pipeline processes raw patient clinical data, insurance records, and medical procedures to generate clean, highly-optimized analytical tables for Business Intelligence (BI) and reporting.

---

## 📊 Pipeline Architecture

The pipeline implements a decoupled, layered data modeling architecture (Staging and Marts) to guarantee data quality and maintainability.

```mermaid
graph TD
    subgraph Raw Layer (Snowflake Public Schema)
        S1[(patients)]
        S2[(conditions)]
        S3[(procedures)]
        S4[(payers)]
        S5[(payer_transitions)]
    end

    subgraph Staging Layer (materialized: view, schema: STAGING)
        STG1[stg_healthcare__patients_n]
        STG2[stg_healthcare__conditions_n]
        STG3[stg_healthcare__procedures_n]
        STG4[stg_healthcare__payers_n]
        STG5[stg_healthcare__payer_transitions_n]
    end

    subgraph Marts Layer (materialized: table, schema: MARTS)
        M1[mart_condition_cost_by_payer]
    end

    S1 --> STG1
    S2 --> STG2
    S3 --> STG3
    S4 --> STG4
    S5 --> STG5

    STG3 --> M1
    STG4 --> M1
    STG5 --> M1
```

### 1. Staging Layer (`models/staging/`)
* **Materialization:** `view`
* **Role:** Acts as the clean ingestion gateway. It references raw tables via `{{ source() }}`, enforces strict Snowflake casting (dates, integers, decimals), standardizes naming conventions (e.g., camel_case to snake_case), and cleans null values.
* **Models:**
  * `stg_healthcare__patients_n`: Patient demographics and details.
  * `stg_healthcare__conditions_n`: Diagnoses and conditions.
  * `stg_healthcare__procedures_n`: Performed procedures and costs.
  * `stg_healthcare__payers_n`: Insurance provider details.
  * `stg_healthcare__payer_transitions_n`: History of insurance enrollment per patient.

### 2. Marts Layer (`models/marts/`)
* **Materialization:** `table`
* **Role:** Aggregates multi-entity staging views into highly-indexed business-facing tables for dashboard reporting.
* **Core Model:** `mart_condition_cost_by_payer`: 
  * Computes each patient's **current active payer** by evaluating historical transitions using window functions (`row_number()`).
  * Aggregates total procedures, average costs, total costs, and patient count grouped by procedure code and insurance provider.

---

## 🛠️ Getting Started & Installation

### Prerequisites
* **Python 3.8+**
* **dbt-core & dbt-snowflake** (`pip install dbt-snowflake`)

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shashidharsd5046/snowflake_dbt_healthcare_project.git
   cd snowflake_dbt_healthcare_project
   ```

2. **Configure Environment Variables:**
   Create a `.env` file in the root of the project to securely load your Snowflake password:
   ```env
   DBT_SNOWFLAKE_PASSWORD="your_snowflake_password_here"
   ```

3. **Verify Connection:**
   Load the environment variables and test the connection to your Snowflake account:
   ```bash
   export $(cat .env | xargs)
   dbt debug
   ```

---

## 🚀 Running the Pipeline

Use the standard dbt CLI commands to compile, run, and test your models.

### Run All Models
Compiles the staging views and builds the mart tables in Snowflake:
```bash
export $(cat .env | xargs)
dbt run
```

### Run Data Tests
Executes all uniqueness, non-null, and relationship integrity tests defined in your `.yml` configuration schemas:
```bash
export $(cat .env | xargs)
dbt test
```

### Build & Test (Recommended)
Interleaves both model building and testing, ensuring downstream models are skipped if an upstream test fails:
```bash
export $(cat .env | xargs)
dbt build
```

---

## 🧪 Data Quality Tests

This project enforces strict data quality using out-of-the-box dbt schema assertions:
* **Unique & Not Null:** Enforced on primary keys (`patient_id`, `payer_id`, `encounter_id`).
* **Relationship Integrity:** Ensures transition tables refer only to valid identifiers.
* **Audit Trails:** Run tests with the `--store-failures` flag to write violating rows into a dedicated Snowflake auditing schema for easy debugging:
  ```bash
  dbt test --store-failures
  ```

-- stg_healthcare__procedures.sql
-- Staged procedure records from healthcare stage CSV

with source as (
    select
        $1 as procedure_date,
        $2 as patient_id,
        $3 as encounter_id,
        $4 as code,
        $5 as description,
        $6 as base_cost,
        $7 as reasoncode,
        $8 as reasondescription
    from @HEALTHCARE_DATE.PUBLIC.HEALTHCARE_STAGE/procedures.csv
        (file_format => 'HEALTHCARE_DATE.PUBLIC.csv_data')
),

staged as (
    select
        patient_id::varchar as patient_id,
        encounter_id::varchar as encounter_id,
        code::varchar as procedure_code,
        description::varchar as procedure_description,
        procedure_date::timestamp as procedure_date,
        base_cost::numeric(12,2) as base_cost,
        nullif(reasoncode, 'None')::varchar as reason_code,
        nullif(reasondescription, 'None')::varchar as reason_description
    from source
)

select * from staged

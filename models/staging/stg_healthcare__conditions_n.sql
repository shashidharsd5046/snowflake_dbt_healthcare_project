-- stg_healthcare__conditions.sql
-- Staged condition records from healthcare stage CSV

with source as (
    select
        $1 as start_date,
        $2 as stop_date,
        $3 as patient_id,
        $4 as encounter_id,
        $5 as code,
        $6 as description
    from @HEALTHCARE_DATE.PUBLIC.HEALTHCARE_STAGE/conditions.csv
        (file_format => 'HEALTHCARE_DATE.PUBLIC.csv_data')
),

staged as (
    select
        patient_id::varchar as patient_id,
        encounter_id::varchar as encounter_id,
        code::varchar as condition_code,
        description::varchar as condition_description,
        start_date::date as condition_start_date,
        nullif(stop_date, 'None')::date as condition_stop_date
    from source
)

select * from staged

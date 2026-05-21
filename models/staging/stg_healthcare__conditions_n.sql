-- stg_healthcare__conditions.sql
-- Staged condition records from healthcare source

with source as (
    select * from {{ source('healthcare_raw', 'conditions') }}
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

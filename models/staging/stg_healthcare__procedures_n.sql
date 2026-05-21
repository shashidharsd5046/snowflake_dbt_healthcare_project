-- stg_healthcare__procedures.sql
-- Staged procedure records from healthcare source

with source as (
    select * from {{ source('healthcare_raw', 'procedures') }}
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

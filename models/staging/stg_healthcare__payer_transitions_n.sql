-- stg_healthcare__payer_transitions.sql
-- Staged payer transition records from healthcare source

with source as (
    select * from {{ source('healthcare_raw', 'payer_transitions') }}
),

staged as (
    select
        patient_id::varchar as patient_id,
        start_year::int as payer_start_year,
        end_year::int as payer_end_year,
        payer_id::varchar as payer_id,
        ownership::varchar as ownership
    from source
)

select * from staged

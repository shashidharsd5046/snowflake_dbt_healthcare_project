-- stg_healthcare__payers.sql
-- Staged payer records from healthcare source

with source as (
    select * from {{ source('healthcare_raw', 'payers') }}
),

staged as (
    select
        payer_id::varchar as payer_id,
        name::varchar as payer_name,
        address::varchar as payer_address,
        city::varchar as payer_city,
        state_headquartered::varchar as payer_state,
        zip::varchar as payer_zip,
        phone::varchar as payer_phone,
        amount_covered::numeric(12,2) as amount_covered,
        amount_uncovered::numeric(12,2) as amount_uncovered,
        revenue::numeric(12,2) as revenue
    from source
)

select * from staged

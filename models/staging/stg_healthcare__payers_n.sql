-- stg_healthcare__payers.sql
-- Staged payer records from healthcare stage CSV

with source as (
    select
        $1 as payer_id,
        $2 as name,
        $3 as address,
        $4 as city,
        $5 as state_headquartered,
        $6 as zip,
        $7 as phone,
        $8 as amount_covered,
        $9 as amount_uncovered,
        $10 as revenue
    from @HEALTHCARE_DATE.PUBLIC.HEALTHCARE_STAGE/payers.csv
        (file_format => 'HEALTHCARE_DATE.PUBLIC.csv_data')
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

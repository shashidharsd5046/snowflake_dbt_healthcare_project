-- stg_healthcare__payer_transitions.sql
-- Staged payer transition records from healthcare stage CSV

with source as (
    select
        $1 as patient_id,
        $2 as start_year,
        $3 as end_year,
        $4 as payer_id,
        $5 as ownership
    from @HEALTHCARE_DATE.PUBLIC.HEALTHCARE_STAGE/payer_transitions.csv
        (file_format => 'HEALTHCARE_DATE.PUBLIC.csv_data')
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

-- stg_healthcare__patients.sql
-- Staged patient records from healthcare stage CSV

with source as (
    select
        $1 as patient_id,
        $2 as birthdate,
        $3 as deathdate,
        $4 as ssn,
        $5 as drivers,
        $6 as passport,
        $7 as prefix,
        $8 as first_name,
        $9 as last_name,
        $10 as suffix,
        $11 as maiden,
        $12 as marital,
        $13 as race,
        $14 as ethnicity,
        $15 as gender,
        $16 as birthplace,
        $17 as address,
        $18 as city,
        $19 as state,
        $20 as county,
        $21 as zip,
        $22 as lat,
        $23 as lon,
        $24 as healthcare_expenses,
        $25 as healthcare_coverage
    from @HEALTHCARE_DATE.PUBLIC.HEALTHCARE_STAGE/patients.csv
        (file_format => 'HEALTHCARE_DATE.PUBLIC.csv_data')
),

staged as (
    select
        patient_id::varchar as patient_id,
        birthdate::date as birthdate,
        nullif(deathdate, 'None')::date as deathdate,
        ssn::varchar as ssn,
        first_name::varchar as first_name,
        last_name::varchar as last_name,
        gender::varchar as gender,
        race::varchar as race,
        ethnicity::varchar as ethnicity,
        city::varchar as city,
        state::varchar as state,
        county::varchar as county,
        zip::varchar as zip,
        lat::float as latitude,
        lon::float as longitude,
        healthcare_expenses::numeric(12,2) as healthcare_expenses,
        healthcare_coverage::numeric(12,2) as healthcare_coverage
    from source
)

select * from staged

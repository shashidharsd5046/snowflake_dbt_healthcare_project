-- stg_healthcare__patients.sql
-- Staged patient records from healthcare source

with source as (
    select * from {{ source('healthcare_raw', 'patients') }}
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

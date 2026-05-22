-- mart_patient_procedure_summary.sql
-- Mart: Summary of procedure counts and costs at the patient level
-- Grain: One row per patient

with patients as (
    select * from {{ ref('stg_healthcare__patients_n') }}
),

procedures as (
    select * from {{ ref('stg_healthcare__procedures_n') }}
),

patient_aggregates as (
    select
        patient_id,
        count(*) as total_procedures,
        sum(base_cost) as total_procedure_cost,
        avg(base_cost) as avg_procedure_cost
    from procedures
    group by patient_id
),

final as (
    select
        p.patient_id,
        p.first_name,
        p.last_name,
        p.gender,
        p.city,
        p.state,
        coalesce(pa.total_procedures, 0) as total_procedures,
        coalesce(pa.total_procedure_cost, 0.00) as total_procedure_cost,
        coalesce(pa.avg_procedure_cost, 0.00) as avg_procedure_cost
    from patients p
    left join patient_aggregates pa
        on p.patient_id = pa.patient_id
)

select * from final
order by total_procedure_cost desc

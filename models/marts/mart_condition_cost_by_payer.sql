-- mart_condition_cost_by_payer.sql
-- Mart: Total procedure cost by procedure grouped by payer
-- Grain: one row per payer + procedure combination

with procedures as (
    select * from {{ ref('stg_healthcare__procedures_n') }}
),

payer_transitions as (
    select * from {{ ref('stg_healthcare__payer_transitions_n') }}
),

payers as (
    select * from {{ ref('stg_healthcare__payers_n') }}
),

-- Get the most recent payer for each patient based on payer_transitions
-- Using the latest end_year to determine current payer
patient_payers as (
    select
        pt.patient_id,
        pt.payer_id,
        py.payer_name,
        row_number() over (
            partition by pt.patient_id
            order by pt.payer_end_year desc, pt.payer_start_year desc
        ) as rn
    from payer_transitions pt
    inner join payers py
        on pt.payer_id = py.payer_id
),

current_patient_payer as (
    select
        patient_id,
        payer_id,
        payer_name
    from patient_payers
    where rn = 1
),

-- Final aggregation: procedure cost by payer
final as (
    select
        coalesce(cpp.payer_name, 'Unknown payer') as payer_name,
        p.procedure_code,
        p.procedure_description,
        count(distinct p.patient_id) as total_patients,
        count(*) as total_procedures,
        sum(p.base_cost) as total_cost,
        avg(p.base_cost) as avg_cost_per_procedure
    from procedures p
    left join current_patient_payer cpp
        on p.patient_id = cpp.patient_id
    group by
        coalesce(cpp.payer_name, 'Unknown payer'),
        p.procedure_code,
        p.procedure_description
)

select * from final
order by total_cost desc

-- mart_payer_procedure_cost_summary.sql
-- Mart: Total and average procedure cost grouped by payer
-- Grain: One row per payer

with procedures as (
    select * from {{ ref('stg_healthcare__procedures_n') }}
),

payer_transitions as (
    select * from {{ ref('stg_healthcare__payer_transitions_n') }}
),

payers as (
    select * from {{ ref('stg_healthcare__payers_n') }}
),

-- Get the most recent payer for each patient
patient_payers as (
    select
        pt.patient_id,
        pt.payer_id,
        py.payer_name,
        py.payer_state,
        py.amount_covered,
        py.amount_uncovered,
        py.revenue,
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
        payer_name,
        payer_state,
        amount_covered,
        amount_uncovered,
        revenue
    from patient_payers
    where rn = 1
),

-- Join procedures to payers and aggregate
final as (
    select
        coalesce(cpp.payer_name, 'Unknown Payer')   as payer_name,
        coalesce(cpp.payer_state, 'Unknown')         as payer_state,
        count(distinct p.patient_id)                 as total_patients,
        count(*)                                     as total_procedures,
        sum(p.base_cost)                             as total_procedure_cost,
        avg(p.base_cost)                             as avg_procedure_cost,
        min(p.base_cost)                             as min_procedure_cost,
        max(p.base_cost)                             as max_procedure_cost
    from procedures p
    left join current_patient_payer cpp
        on p.patient_id = cpp.patient_id
    group by
        coalesce(cpp.payer_name, 'Unknown Payer'),
        coalesce(cpp.payer_state, 'Unknown')
)

select * from final
order by total_procedure_cost desc

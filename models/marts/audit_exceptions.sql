{{ config(contract={'enforced': true}) }}

-- Standard exception schema over the full-population tests.
with all_exceptions as (
    select * from {{ ref('int_test_duplicate_invoices') }}
    union all
    select * from {{ ref('int_test_split_purchases') }}
    union all
    select * from {{ ref('int_test_payments_after_bank_change') }}
    union all
    select * from {{ ref('int_test_sod_conflicts') }}
    union all
    select * from {{ ref('int_test_leavers_with_access') }}
    union all
    select * from {{ ref('int_test_payments_before_vendor') }}
    union all
    select * from {{ ref('int_test_duplicate_invoices_fuzzy') }}
    union all
    select * from {{ ref('int_test_benford_vendor') }}
    union all
    select * from {{ ref('int_test_je_round_amount') }}
    union all
    select * from {{ ref('int_test_je_weekend_holiday') }}
    union all
    select * from {{ ref('int_test_je_unauthorized_poster') }}
)

select
    test_id::varchar as test_id,
    entity::varchar as entity,
    risk::varchar as risk,
    evidence::varchar as evidence,
    current_timestamp::timestamp as detected_at
from all_exceptions

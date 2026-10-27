{{ config(contract={'enforced': true}) }}

-- One row per general-ledger journal with control attributes for journal-entry testing.
select
    je_id::varchar as je_id,
    posting_date::date as posting_date,
    fiscal_period::varchar as fiscal_period,
    debit_account::integer as debit_account,
    credit_account::integer as credit_account,
    journal_amount::decimal(18, 2) as journal_amount,
    journal_source::varchar as journal_source,
    posted_by_user_id::varchar as posted_by_user_id,
    is_manual,
    is_weekend,
    is_holiday,
    is_round_amount,
    poster_can_post_journal
from {{ ref('int_journal_flags') }}

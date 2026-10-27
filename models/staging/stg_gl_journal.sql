select
    cast(je_id as varchar) as je_id,
    cast(posting_date as date) as posting_date,
    cast(period as varchar) as fiscal_period,
    cast(debit_account as integer) as debit_account,
    cast(credit_account as integer) as credit_account,
    cast(amount as decimal(18, 2)) as journal_amount,
    upper(cast(source as varchar)) as journal_source,
    cast(posted_by as varchar) as posted_by_user_id,
    cast(description as varchar) as description,
    cast(reference as varchar) as reference
from {{ source('raw', 'gl_journal') }}

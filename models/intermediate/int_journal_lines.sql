-- Unpivots each journal into its debit and credit legs so balance can be tested per journal.
-- A missing account on either side yields no leg, which makes the journal unbalanced by design.
select
    je_id,
    'D' as side,
    debit_account as account,
    journal_amount as amount
from {{ ref('stg_gl_journal') }}
where debit_account is not null

union all

select
    je_id,
    'C' as side,
    credit_account as account,
    journal_amount as amount
from {{ ref('stg_gl_journal') }}
where credit_account is not null

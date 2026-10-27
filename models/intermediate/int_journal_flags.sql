-- Control attributes per journal. Shared by fct_journal_entries and the three journal-entry tests,
-- so a flag means the same thing in the mart and in audit_exceptions.
with posters as (
    select
        user_id,
        can_post_journal
    from {{ ref('int_user_access') }}
)

select
    j.je_id,
    j.posting_date,
    j.fiscal_period,
    j.debit_account,
    j.credit_account,
    j.journal_amount,
    j.journal_source,
    j.posted_by_user_id,
    j.description,
    h.holiday_name,
    (j.journal_source = 'MANUAL') as is_manual,
    (dayofweek(j.posting_date) in (0, 6)) as is_weekend,
    (h.holiday_date is not null) as is_holiday,
    (
        j.journal_amount >= {{ var('round_min_amount') }}
        and j.journal_amount % {{ var('round_modulus') }} = 0
    ) as is_round_amount,
    coalesce(po.can_post_journal, false) as poster_can_post_journal
from {{ ref('stg_gl_journal') }} as j
left join {{ ref('stg_holidays') }} as h on j.posting_date = h.holiday_date
left join posters as po on j.posted_by_user_id = po.user_id

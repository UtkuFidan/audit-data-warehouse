-- Full-population test je_weekend_holiday: manual journals posted on a Saturday, Sunday or holiday.
select
    'je_weekend_holiday' as test_id,
    je_id as entity,
    'Management override of controls' as risk,
    'Manual journal ' || je_id || ' of ' || format('{:.2f}', journal_amount) || ' posted by '
    || posted_by_user_id || ' on ' || cast(posting_date as varchar) || ' (' || dayname(posting_date)
    || coalesce(', ' || holiday_name, '') || ')' as evidence
from {{ ref('int_journal_flags') }}
where is_manual and (is_weekend or is_holiday)

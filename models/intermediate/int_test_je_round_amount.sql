-- Full-population test je_round_amount: manual journals that are an exact multiple of the round
-- modulus and at least the minimum amount (cents included, so 20,000.00 qualifies and 20,000.37 not).
select
    'je_round_amount' as test_id,
    je_id as entity,
    'Management override of controls' as risk,
    'Manual journal ' || je_id || ' of ' || format('{:.2f}', journal_amount) || ' posted by '
    || posted_by_user_id || ' on ' || cast(posting_date as varchar) || ' is a round amount' as evidence
from {{ ref('int_journal_flags') }}
where is_manual and is_round_amount

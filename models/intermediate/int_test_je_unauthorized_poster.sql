-- Full-population test je_unauthorized_poster: manual journals posted by a user whose roles
-- carry no post_journal permission.
select
    'je_unauthorized_poster' as test_id,
    je_id as entity,
    'Unauthorised access' as risk,
    'Manual journal ' || je_id || ' of ' || format('{:.2f}', journal_amount) || ' posted by '
    || posted_by_user_id || ' on ' || cast(posting_date as varchar) || ', who holds no post_journal permission'
        as evidence
from {{ ref('int_journal_flags') }}
where is_manual and not poster_can_post_journal

-- Full-population test leaver_active_account: ACTIVE account although the HR leave date has passed.
select
    'leaver_active_account' as test_id,
    user_id as entity,
    'Unauthorised access' as risk,
    'User ' || user_id || ' (' || employee_id || ') is ACTIVE; left on ' || cast(leave_date as varchar)
    || ', ' || date_diff('day', leave_date, cast('{{ var("as_of_date") }}' as date)) || ' days before cut-off'
    || case when last_login_date > leave_date then '; last login ' || cast(last_login_date as varchar) || ' is after leaving' else '' end
        as evidence
from {{ ref('int_user_access') }}
where
    account_status = 'ACTIVE'
    and leave_date <= cast('{{ var("as_of_date") }}' as date)

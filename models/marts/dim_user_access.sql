{{ config(contract={'enforced': true}) }}

-- One row per user account with access profile and control flags.
select
    u.user_id::varchar as user_id,
    u.employee_id::varchar as employee_id,
    u.department::varchar as department,
    u.account_status::varchar as account_status,
    u.leave_date::date as leave_date,
    u.last_login_date::date as last_login_date,
    u.role_count::integer as role_count,
    u.role_list::varchar as role_list,
    u.has_privileged_role::boolean as has_privileged_role,
    u.can_post_journal::boolean as can_post_journal,
    (s.entity is not null) as has_sod_conflict,
    (l.entity is not null) as is_leaver_with_access
from {{ ref('int_user_access') }} as u
left join {{ ref('int_test_sod_conflicts') }} as s on u.user_id = s.entity
left join {{ ref('int_test_leavers_with_access') }} as l on u.user_id = l.entity

-- One row per user account with its HR record, roles and derived access attributes.
with role_detail as (
    select
        ur.user_id,
        ur.role_name,
        r.is_privileged,
        coalesce(
            bool_or(rp.permission_name = 'post_journal') over (partition by ur.user_id, ur.role_name),
            false
        ) as grants_post_journal
    from {{ ref('stg_user_roles') }} as ur
    left join {{ ref('stg_roles') }} as r on ur.role_name = r.role_name
    left join {{ ref('stg_role_permissions') }} as rp on ur.role_name = rp.role_name
),

role_summary as (
    select
        user_id,
        count(distinct role_name) as role_count,
        string_agg(distinct role_name, ', ' order by role_name) as role_list,
        coalesce(bool_or(is_privileged), false) as has_privileged_role,
        coalesce(bool_or(grants_post_journal), false) as can_post_journal
    from role_detail
    group by user_id
)

select
    u.user_id,
    u.employee_id,
    u.account_status,
    u.created_date,
    u.last_login_date,
    e.department,
    e.leave_date,
    coalesce(rs.role_count, 0) as role_count,
    rs.role_list,
    coalesce(rs.has_privileged_role, false) as has_privileged_role,
    coalesce(rs.can_post_journal, false) as can_post_journal
from {{ ref('stg_user_accounts') }} as u
left join {{ ref('stg_employees') }} as e on u.employee_id = e.employee_id
left join role_summary as rs on u.user_id = rs.user_id

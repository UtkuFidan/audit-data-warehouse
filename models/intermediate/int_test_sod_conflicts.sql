-- Full-population test sod_conflict: users holding both roles of a pair in the SoD matrix.
select
    'sod_conflict' as test_id,
    a.user_id as entity,
    'Segregation of duties' as risk,
    'User ' || a.user_id || ' holds '
    || string_agg(m.role_a_name || ' + ' || m.role_b_name, '; ' order by m.role_a_name, m.role_b_name) as evidence
from {{ ref('stg_user_roles') }} as a
inner join {{ ref('stg_user_roles') }} as b on a.user_id = b.user_id
inner join {{ ref('stg_sod_matrix') }} as m
    on a.role_name = m.role_a_name and b.role_name = m.role_b_name
group by a.user_id

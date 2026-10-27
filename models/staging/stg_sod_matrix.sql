select
    cast(role_a as varchar) as role_a_name,
    cast(role_b as varchar) as role_b_name,
    cast(rationale as varchar) as rationale
from {{ source('raw', 'sod_matrix') }}

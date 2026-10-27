select
    cast(role as varchar) as role_name,
    cast(is_privileged as boolean) as is_privileged,
    cast(description as varchar) as role_description
from {{ source('raw', 'roles') }}

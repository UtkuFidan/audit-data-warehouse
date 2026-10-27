select
    cast(role as varchar) as role_name,
    cast(permission as varchar) as permission_name
from {{ source('raw', 'role_permissions') }}

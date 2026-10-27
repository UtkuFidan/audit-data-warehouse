select
    cast(user_id as varchar) as user_id,
    cast(role as varchar) as role_name
from {{ source('raw', 'user_roles') }}

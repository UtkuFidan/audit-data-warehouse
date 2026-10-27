select
    cast(user_id as varchar) as user_id,
    cast(employee_id as varchar) as employee_id,
    upper(cast(status as varchar)) as account_status,
    cast(created_date as date) as created_date,
    cast(last_login as date) as last_login_date
from {{ source('raw', 'user_accounts') }}

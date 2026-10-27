select
    cast(employee_id as varchar) as employee_id,
    cast(department as varchar) as department,
    cast(hire_date as date) as hire_date,
    cast(leave_date as date) as leave_date
from {{ source('raw', 'employees') }}

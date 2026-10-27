select
    cast(holiday_date as date) as holiday_date,
    cast(name as varchar) as holiday_name
from {{ source('raw', 'holidays') }}

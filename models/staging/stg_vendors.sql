select
    cast(vendor_id as varchar) as vendor_id,
    cast(name as varchar) as vendor_name,
    upper(cast(country as varchar)) as country_code,
    cast(tax_id as varchar) as tax_id,
    cast(bank_iban as varchar) as current_bank_iban,
    cast(created_date as date) as created_date
from {{ source('raw', 'vendors') }}

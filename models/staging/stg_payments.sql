select
    cast(payment_id as varchar) as payment_id,
    cast(invoice_id as varchar) as invoice_id,
    cast(vendor_id as varchar) as vendor_id,
    cast(payment_date as date) as payment_date,
    cast(amount as decimal(18, 2)) as payment_amount,
    cast(bank_iban as varchar) as bank_iban
from {{ source('raw', 'payments') }}

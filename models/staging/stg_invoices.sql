select
    cast(invoice_id as varchar) as invoice_id,
    cast(vendor_id as varchar) as vendor_id,
    upper(trim(cast(invoice_number as varchar))) as invoice_number,
    cast(invoice_date as date) as invoice_date,
    cast(amount as decimal(18, 2)) as invoice_amount,
    cast(po_id as varchar) as po_id
from {{ source('raw', 'invoices') }}

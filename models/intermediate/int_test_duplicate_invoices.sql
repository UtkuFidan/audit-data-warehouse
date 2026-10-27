-- Full-population test dup_invoice_exact: same vendor, invoice number and amount.
-- The earliest copy is the original; every later copy is an exception.
with ranked as (
    select
        *,
        row_number() over w as copy_number,
        first_value(invoice_id) over w as original_invoice_id
    from {{ ref('stg_invoices') }}
    window w as (
        partition by vendor_id, invoice_number, invoice_amount
        order by invoice_date, invoice_id
    )
)

select
    'dup_invoice_exact' as test_id,
    invoice_id as entity,
    'Double payment' as risk,
    'Invoice ' || invoice_id || ' (' || invoice_number || ', ' || vendor_id || ', '
    || format('{:.2f}', invoice_amount) || ') repeats ' || original_invoice_id as evidence
from ranked
where copy_number > 1

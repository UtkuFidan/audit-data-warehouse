{{ config(contract={'enforced': true}) }}

-- One row per payment, joined to the vendor version valid on the payment date.
-- A payment dated before the vendor was created falls back to the first version and is flagged.
with bank_change_flags as (
    select
        entity as payment_id,
        true as is_after_bank_change
    from {{ ref('int_test_payments_after_bank_change') }}
)

select
    p.payment_id::varchar as payment_id,
    p.invoice_id::varchar as invoice_id,
    p.vendor_id::varchar as vendor_id,
    d.vendor_sk::varchar as vendor_sk,
    p.payment_date::date as payment_date,
    p.payment_amount::decimal(18, 2) as payment_amount,
    i.invoice_amount::decimal(18, 2) as invoice_amount,
    p.bank_iban::varchar as bank_iban,
    (p.bank_iban = d.bank_iban) as is_iban_on_file,
    (p.payment_amount <> i.invoice_amount) as is_amount_mismatch,
    coalesce(f.is_after_bank_change, false) as is_after_bank_change,
    (p.payment_date < v.created_date) as is_before_vendor_creation
from {{ ref('stg_payments') }} as p
left join {{ ref('stg_invoices') }} as i on p.invoice_id = i.invoice_id
left join {{ ref('dim_vendor') }} as d
    on
        p.vendor_id = d.vendor_id
        and (
            (p.payment_date >= d.valid_from and p.payment_date < d.valid_to)
            or (d.version_number = 1 and p.payment_date < d.valid_from)
        )
left join {{ ref('stg_vendors') }} as v on p.vendor_id = v.vendor_id
left join bank_change_flags as f on p.payment_id = f.payment_id

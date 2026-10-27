-- Full-population test dup_invoice_fuzzy: same amount, invoice dates within fuzzy_date_days, and
-- either the same vendor or near-identical vendor names (the supplier exists twice in the master).
-- Exact duplicates (same vendor and number) belong to dup_invoice_exact and are excluded.
-- Each later invoice is reported once, against its earliest matching predecessor.
with invoices as (
    select
        i.invoice_id,
        i.vendor_id,
        i.invoice_number,
        i.invoice_date,
        i.invoice_amount,
        regexp_replace(
            replace(replace(lower(v.vendor_name), 'limited', 'ltd'), 'incorporated', 'inc'),
            '[^a-z0-9]', '', 'g'
        ) as name_norm
    from {{ ref('stg_invoices') }} as i
    inner join {{ ref('stg_vendors') }} as v on i.vendor_id = v.vendor_id
),

pairs as (
    select
        b.invoice_id,
        b.vendor_id,
        b.invoice_number,
        b.invoice_amount,
        a.invoice_id as matched_invoice_id,
        a.vendor_id as matched_vendor_id,
        date_diff('day', a.invoice_date, b.invoice_date) as days_apart
    from invoices as a
    inner join invoices as b
        on
            a.invoice_amount = b.invoice_amount
            and (b.invoice_date, b.invoice_id) > (a.invoice_date, a.invoice_id)
    where
        date_diff('day', a.invoice_date, b.invoice_date) <= {{ var('fuzzy_date_days') }}
        and not (a.vendor_id = b.vendor_id and a.invoice_number = b.invoice_number)
        and (
            a.vendor_id = b.vendor_id
            or jaro_winkler_similarity(a.name_norm, b.name_norm) >= {{ var('fuzzy_name_similarity') }}
        )
    qualify row_number() over (partition by b.invoice_id order by a.invoice_date, a.invoice_id) = 1
)

select
    'dup_invoice_fuzzy' as test_id,
    invoice_id as entity,
    'Double payment' as risk,
    'Invoice ' || invoice_id || ' (' || invoice_number || ', ' || vendor_id || ', '
    || format('{:.2f}', invoice_amount) || ') matches ' || matched_invoice_id
    || case when matched_vendor_id = vendor_id then ' of the same vendor' else ' of ' || matched_vendor_id end
    || ', ' || days_apart || '-day gap, different invoice number' as evidence
from pairs

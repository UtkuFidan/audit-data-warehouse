-- Full-population test benford_vendor: vendors with enough invoices whose first digits reject
-- Benford's law at the configured significance level.
select
    'benford_vendor' as test_id,
    vendor_id as entity,
    'Fabricated or manipulated amounts' as risk,
    'Vendor ' || vendor_id || ': ' || invoice_count || ' invoices, chi-square ' || format('{:.1f}', chi_square)
    || ', p ' || format('{:.2e}', p_value) || ', MAD ' || format('{:.4f}', mad) || ' (' || conformity || ')'
        as evidence
from {{ ref('int_vendor_benford') }}
where
    invoice_count >= {{ var('benford_min_invoices') }}
    and p_value < {{ var('benford_alpha') }}

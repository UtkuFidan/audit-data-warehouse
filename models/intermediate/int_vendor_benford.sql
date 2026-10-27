-- First-digit (Benford) statistics per vendor over positive invoice amounts: chi-square against
-- the Benford expectation, its p-value, and Nigrini's mean absolute deviation (MAD).
with digits as (
    select
        vendor_id,
        cast(left(ltrim(replace(cast(invoice_amount as varchar), '.', ''), '0'), 1) as integer) as digit
    from {{ ref('stg_invoices') }}
    where invoice_amount > 0
),

expected as (
    select
        digit,
        log10(1 + 1.0 / digit) as share
    from (select unnest(range(1, 10)) as digit) as digits_1_to_9
),

vendors as (
    select
        vendor_id,
        count(*) as n
    from digits
    group by vendor_id
),

grid as (
    select
        v.vendor_id,
        v.n,
        e.digit,
        e.share,
        count(d.digit) as observed
    from vendors as v
    cross join expected as e
    left join digits as d on v.vendor_id = d.vendor_id and e.digit = d.digit
    group by v.vendor_id, v.n, e.digit, e.share
),

stats as (
    select
        vendor_id,
        n,
        sum(power(observed - n * share, 2) / (n * share)) as chi_square,
        avg(abs(observed / n - share)) as mad
    from grid
    group by vendor_id, n
)

select
    vendor_id,
    n as invoice_count,
    chi_square,
    {{ chi2_sf_df8('chi_square') }} as p_value,
    mad,
    case
        when mad <= 0.006 then 'close conformity'
        when mad <= 0.012 then 'acceptable conformity'
        when mad <= 0.015 then 'marginally acceptable conformity'
        else 'nonconformity'
    end as conformity
from stats
